# Eventual for Flutter

Eventual provides a flexible and composable toolkit to perform State Management. Track the status of **eventual** data, **notify** the UI when changes occur and **rebuild** the relevant widget subtree accordingly.

This package allows for great flexibility in complex scenarios while keeping the focus on a clean and simple approach.

With Eventual you can:
- Split the data lifecycle from the UI
- Keep the UI simple and always in sync
- Work with composable and straightforward data repositories
- Render collections and deep structures efficiently
- Track the availability of data and show only relevant pixels
- Track whether values are fresh or need updating
- Get leaner stateful widgets than `StatefulWidget`

## Getting Started

### Setting some eventual data

Create your first `EventualNotifier` wrapping an `int`:

```dart
export "package:eventual/eventual.dart";

void main() {
  // No value by default
  final someScore = EventualNotifier<int>();
  print(someScore.value); // null
  print(someScore.hasValue); // false
  
  // With a default value
  final userScore = EventualNotifier<int>(42);
  print(userScore.value); // 42
}
```

Set the status to `loading` before you fetch data from somewhere:

```dart
{
  // ...

  // Set to loading, but keep the value
  userScore.loading = true;
  
  print(userScore.value); // 42
  print(userScore.isLoading); // true

  final newValue = await successfulNumberFetch(/*...*/);
}
```

Get the new value and update it (stops `loading`)

```dart
{
  // ...

  // Set the new value
  userScore.value = newValue;
  
  print(userScore.value); // 110
  print(userScore.hasValue); // true
  print(userScore.isLoading); // false
}
```

Set to `loading` again, and fetch a value that may fail:

```dart
{
  // ...
  userScore.loadingMessage = "Please, wait...";

  try {
    // This would update the value if successful, but...
    userScore.value = await failingNumberFetch(/*...*/);
  } catch (err) {
    // Stops loading, keeps the previous value
    // and sets the error message
    userScore.error = "Something went wrong";
  }
  
  print(userScore.value); // 42
  print(userScore.isLoading); // false
  print(userScore.hasError); // true
  print(userScore.errorMessage); // "Something went wrong"
}
```

### Displaying our eventual notifiers

Now we have an `EventualNotifier` with data. Let's consume it on our Widget tree with an `EventualBuilder`:

```dart
class MyWidget extends StatelessWidget {
  final EventualNotifier<int> userScore = EventualNotifier<int>();

  const MyWidget(this.userScore) {
    refreshScore();
  }

  @override
  Widget build(BuildContext context) {
    // The widget consumes our eventual data from userScore

    return EventualBuilder(
      notifier: userScore,
      // notifiers: [userScore, ...],
      builder: (context, notifiers, child) {
        // This builder reruns every time that `userScore` changes

        // Is it still loading?
        if (userScore.loading) return Text(userScore.loadingMessage ?? "Loading...");
        
        // Is there an error?
        if (!userScore.hasValue) return Text("The user has no score");
        else if (userScore.hasError) return Text(userScore.errorMessage);
        
        // All good, use the value
        return Text("The user has a score of ${userScore.value}");
      }
    );
  }

  // Eventual data being updated
  refreshScore() {
    userScore.loading = true;

    fetchNewScore(...)
      .then((newValue) => userScore.value = newValue)
      .catchError((err) => userScore.error = err.toString());
  }
}
```

`EventualNotifier`'s can be from a global repository or be created locally. In either case, the widget will rebuild to reflect the latest version of the value.

### Single notifier widget

While `EventualNotifier` supports one or more notifiers, you can also use `EventualSingleBuilder` if you only need to consume one.

This provides a cleaner way to achieve a similar result:

```dart
class MyWidget extends StatelessWidget {
  final EventualNotifier<int> userScore;

  const MyWidget(this.userScore) {
    refreshScore();
  }

  @override
  Widget build(BuildContext context) {
    // The widget consumes our eventual data from userScore

    return EventualSingleBuilder(
      notifier: userScore,
      // optional builder
      loadingBuilder: (ctx, notifier, child) => Text(userScore.loadingMessage ?? "Loading..."),
      // optional builder
      errorBuilder: (ctx, notifier, child) => Text(userScore.errorMessage),
      // optional builder
      emptyBuilder: (ctx, notifier, child) => Text("The user has no score"),
      // required
      builder: (ctx, notifier, child) {
        // All good, use the value
        return Text("The user has a score of ${userScore.value}");
      }
    );
  }

  // Eventual data being updated
  refreshScore() {
    userScore.loading = true;

    fetchNewScore(...)
      .then((newValue) => userScore.value = newValue)
      .catchError((err) => userScore.error = err.toString());
  }
}
```

## Collections and data structures

Working with collections of objects is as simple as using a `List<*>` as the actual `value`, whereas struct's can be managed with `Map<*, *>`'s or custom classes. 

`EventualNotifier` does a shallow comparison once a new value is pushed to it. However, **tracking the inner changes** within the `value` itself is **out of the reach** of an `EventualNotifier`. In such case, an explicit notification would be needed with `notifyChange()`.

### Nested change notifications

A better way to be notified when a **nested item changes** is by using `EventualNotifier`'s in layers.

Below is an example that uses `List<EventualNotifiers<int>>` instead of a `List<int>`.

```dart
void main() {
  // A few notifiers
  final num1 = EventualNotifier<int>(10);
  final num2 = EventualNotifier<int>();
  final num3 = EventualNotifier<int>().setError("Invalid number");
  final num4 = EventualNotifier<int>().setToLoading();

  // A list of notifiers
  final numberList = EventualNotifier<List<EventualNotifier<int>>>([num1, num2]);

  // Updating the list, emits an event to all `numberList` consumers
  numberList.value = [num1, num2, num3, num4]; // => EMIT EVENT

  // Updating the item, emits an event to all `num1` consumers, 
  // and not `numberList`
  final notifierItem = numberList.first;
  notifierItem.value = 200; // => EMIT EVENT
}
```

Here is a UI example:

```dart
void main() {
  // Set an empty list
  final userList = EventualNotifier<List<EventualNotifier<String>>>();

  userList.loadingMessage = "Please, wait...";

  // Load some dynaimc data
  myFetchUserList(...).then((users) {
    // Update the list value
    // => Triggers MyUserList > build > EventualBuilder > builder()
    userList.value = users;
  }).catchError((err) {
    // Update the list state
    // => Triggers MyUserList > build > EventualBuilder > builder()
    userList.error = err.toString();
  });

  // Paint the list
  runApp(MaterialApp(
    title: 'Eventual',
    home: Scaffold(
      appBar: AppBar(title: Text('Eventual')),
      body: MyUserList(userList),
    ),
  ));
}

// The collection
class MyUserList extends StatelessWidget {
  final EventualNotifier<List<EventualNotifier<String>>> userList;

  MyUserList(this.userList);
  
  @override
  Widget build(BuildContext context) {
    // Consume the user list
    return EventualSingleBuilder(
      notifier: userList,
      loadingBuilder: (ctx, notifier, child) => Text(userList.loadingMessage ?? "Loading users..."),
      errorBuilder: (ctx, notifier, child) => Text(userList.errorMessage),
      emptyBuilder: (ctx, notifier, child) => Text("There are no users yet"),
      builder: (ctx, notifier, child) {
        // All good, use the value
        final items = userList.value;

        // Build individual children
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext ctx, int index) => MyUserCard(items[index]),
        );
      }
    );
  }
}

// An item
class MyUserCard extends StatelessWidget {
  final EventualNotifier<String> userName;

  MyUserCard(this.userName);
  
  @override
  Widget build(BuildContext context) {
    // Consume an inner notifier
    return EventualSingleBuilder(
      notifier: userName,
      loadingBuilder: (ctx, notifier, child) => Text(userList.loadingMessage ?? "Loading the user's name..."),
      errorBuilder: (ctx, notifier, child) => Text(userList.errorMessage),
      emptyBuilder: (ctx, notifier, child) => Text("This user has no name yet"),
      builder: (ctx, notifier, child) {
        // When `userList[index]` is updated, the appropriate builder reruns

        // All good, use the list value
        final name = userName.value;
        return InkWell(
          child: Text("I am $name\n\nTap to update me"),
          onTap: () {
            // Update the user value
            userName.loading = "This is a fake loading request";
            userName.setError = "Something wrong happened";
            // ...
            userName.value = "I have been tapped";
          }
        );
      }
    );
  }
}
```

This approach allows to efficiently update only the widgets that are using a certain part of the data.
- If the whole list changes, then `MyUserList > ListView.builder()` will rebuild a few rows. 
- But if we update the second list element, then only the affected `MyUserCard` will rebuild (if visible).

This is useful for apps with complex and large collections and data to avoid useless repaint work.

## Leaner Stateful Widgets

With Eventual, you can turn code like this:

```dart
class HomePage extends StatefulWidget {
  final List<UserData> userList; // External data
  final List<String> imageList; // External data

  HomePage(this.userList, this.imageList); // External data

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          buildHeader(),
          buildCounter(),  // The only state-bound branch
          buildUserList(widget.userList),  // expensive build
          buildImageList(widget.imageList),  // expensive build
          buildFooter()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          this.setState(() => counter++); // << Update Counter
        },
        child: Icon(Icons.navigation),
      ),
    );
  }

  Widget buildCounter () {
    return Text("Counter: $counter");
  }

  // ...
}
```

Into a more efficient `StatelessWidget` like this:

```dart

class HomePage extends StatelessWidget {
  final EventualNotifier<int> counter = EventualNotifier<int>(0); // << Our stateful value
  final List<UserData> userList; // External data
  final List<String> imageList; // External data

  HomePage(this.userList, this.imageList); // External data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          buildHeader(),
          buildCounter(),  // The only state-bound branch
          buildUserList(widget.userList),  // expensive build
          buildImageList(widget.imageList),  // expensive build
          buildFooter()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counter.value = counter.value + 1; // << Update Counter
        },
        child: Icon(Icons.navigation),
      ),
    );
  }

  Widget buildCounter () {
    return EventualBuilder(
      notifier: counter,
      builder: (context, _, __) {
        return Text("Counter: $counter");
      },
    );
  }
}
```

You may have spotted a few differences:
- The `StatefulWidget` rebuilds the entire widget even if only `counter` changes
- The "eventual" version calls `build()` just once and `buildCounter()` if needed
- One class vs two classes for one Widget

## EventualNotifier

When using a `EventualNotifier` or a `EventualValue` you can query the following fields:

```dart
void main() {
  final someNumber = EventualNotifier<int>(110);
  
  // The raw value or `null`
  print(someNumber.value);
  
  // Whether a non-null value is set
  print(someNumber.hasValue);
  
  // Whether the value is set to be loading
  print(someNumber.isLoading);
  
  // Whether loading was called up to 10 seconds ago
  // Customizable, see below
  print(someNumber.isLoadingFresh);
  
  // An optional message about what is being loaded or null
  print(someNumber.loadingMessage);
  
  // Whether an error is set
  print(someNumber.hasError);
  
  // The message of the last error
  print(someNumber.errorMessage);
  
  // DateTime when the value was set
  print(someNumber.lastUpdated);
  
  // DateTime when the error was set
  print(someNumber.lastError);
  
  // Whether the value was set 10 or more seconds ago
  // Customizable, see below
  print(someNumber.isFresh);

  // Modifiers

  final someName = EventualNotifier<String>("hello")
    // Consider the value obsolete after 60 seconds
    .withFreshnessTimeout(Duration(seconds: 60))
    // Consider the loading stale after 5 seconds
    .withLoadingTimeout(Duration(seconds: 5));
  
  // Whether the value was set 10 or more seconds ago
  // Customizable, see below
  print(someName.isFresh);

  // Whether loading was called up to 10 seconds ago
  // Customizable, see below
  print(someName.isLoadingFresh);
  
  // Combine them all sequentially

  final someDate = EventualNotifier<DateTime>()
    .setDefaultValue(DateTime.now())
    .withFreshnessTimeout(Duration(seconds: 1))
    .withLoadingTimeout(Duration(milliseconds: 50))
    .setError("Invalid date")
    .setToLoading("Determining the current date")
    .setValue(DateTime.now());
  
  print(someDate.value);  // DateTime(...)
}
```

## Misc

Eventual is inspired on the core concepts behind [Option](https://doc.rust-lang.org/rust-by-example/std/option.html) and [Result](https://doc.rust-lang.org/rust-by-example/std/result.html) from [Rust](https://www.rust-lang.org/);

It also extends many concepts from `ValueNotifier<T>` in [Flutter](https://flutter.dev).

## Future work

- [X] Provide a widget with builders for `loading`, `error` and `value` cases
- [ ] Add a wrapper for lists and maps
