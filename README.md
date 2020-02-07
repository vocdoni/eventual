# Eventual for Flutter

Eventual provides a toolkit to manage **eventual** values, **notify** the UI when changes occur and **rebuild** the relevant widget subtree accordingly.

This package allows for great flexibility in complex scenarios while keeping the focus on clean and simple approach.

With Eventual you can:
- Split the data lifecycle from the UI
- Keep the UI simple and always in sync
- Work with easily composable and usable data repositories
- Rebuild collections and deep structures efficiently
- Track the availability of data and show only relevant pixels
- Track whether values are fresh or need updating
- Leaner stateful widgets than `StatefulWidget`

## Getting Started

Create your first `EventualNotifier` wrapping an `int`:

```dart
export "package:eventual/eventual.dart";

void main() {
  // No value by default
  final someScore = EventualNotifier<int>();
  print(someScore.value); // null
  
  // A default value
  final userScore = EventualNotifier<int>(42);
  print(userScore.value); // 42
  
  // Set to loading, but keep the value
  userScore.loading = true;
  
  print(userScore.value); // 42
  print(userScore.isLoading); // true
  
  // Stop loading and set an error message while
  // the old value is still available
  userScore.error = "Something went wrong";
  
  print(userScore.value); // 42
  print(userScore.isLoading); // false
  print(userScore.hasError); // true
  print(userScore.errorMessage); // "Something went wrong"
  
  // Set to loading with an optional message
  userScore.loadingMessage = "Please, wait";
  
  print(userScore.value); // 42
  print(userScore.isLoading); // false
  print(userScore.loadingMessage); // "Please, wait"
  print(userScore.hasError); // false
  
  // Set a new value
  userScore.value = 110;
  
  print(userScore.value); // 110
  print(userScore.hasValue); // true
}
```

Consume the `EventualNotifier` on your Widget tree with `EventualBuilder`:

```dart
class MyWidget extends StatelessWidget {
  final EventualNotifier<String> userName;
  final EventualNotifier<int> userScore;

  const MyWidget(this.userName, this.userScore) {
    refreshScore();
  }

  @override
  Widget build(BuildContext context) {
    // The widget consumes our eventual data from
    // notifiers [userName, userScore]

    return EventualBuilder(
      notifiers: [userName, userScore],
      builder: (context, notifierList, child) {
        // This builder reruns every time that `userName` or `userScore` change

        // Is it still loading?
        if (userScore.loading) return Text(userScore.loadingMessage ?? "Loading...");
        
        // Does it have an error?
        if (!userScore.hasValue) return Text("${userName.value} has no score");
        else if (userScore.hasError) return Text(userScore.errorMessage);
        
        // All good, use the value
        return Text("${userName.value} has a score of ${userScore.value}");
      }
    );
  }

  // Eventual data being changed
  refreshScore() async {
    userScore.loading = true;
    try {
      final newValue = await fetchNewScore(...),
      userScore.value = newValue; // build is triggered <==
    } catch(err) {
      userScore.error = err.toString(); // build is triggered <==
    }
  }
}
```

`EventualNotifier`'s can come from a global repository or be created locally. In either case, the widget will update to reflect the latest version of the values.

## Collections

Working with collections of objects is as simple as using a `List<*>` as the actual `value`.

However, tracking the state of inner values raises performance concerns and gets out of the scope of an `EventualNotifier`.

```dart
export "package:eventual/eventual.dart";

void main() {
  final numberList = EventualNotifier<List<int>>([]);
  print(numberList.value); // []

  // Setting a new list, emits an event
  numberList.value = [1, 2, 3, 4]; // => EMIT EVENT
  print(numberList.value); // prints [1, 2, 3, 4]
  // EventualBuilder would see [1, 2, 3, 4]

  // However, updating the list itself emits no event
  numberList.value.add(5); // => NO EVENT
  print(numberList.value); // prints [1, 2, 3, 4, 5]
  // EventualBuilder still would see [1, 2, 3, 4]

  // To force a notification, we can call setValue()
  final tempList = numberList.value;
  tempList.add(5);
  numberList.setValue(tempList); // => EMIT EVENT
  print(numberList.value); // prints [1, 2, 3, 4, 5]
  // EventualBuilder now would see [1, 2, 3, 4, 5]

  // Alternatively
  numberList.value.add(6);
  numberList.notifyChange(); // => EMIT EVENT
  print(numberList.value); // prints [1, 2, 3, 4, 5, 6]
  // EventualBuilder would also see [1, 2, 3, 4, 5, 6]
}
```

Is there a way to be notified when an item changes? Depper state can be managed by splitting `EventualNotifier`'s into layers.

In the example above, we could use a `List<EventualNotifiers<int>>` instead of a `List<int>`.

```dart
void main() {
  final numberList = EventualNotifier<List<EventualNotifier<int>>>([]);

  final num1 = EventualNotifier<int>(10);
  final num2 = EventualNotifier<int>();
  final num3 = EventualNotifier<int>().setError("Invalid number");
  final num4 = EventualNotifier<int>().setToLoading();

  // Updating the list, emits an event to all `numberList` consumers
  numberList.value = [num1, num2, num3, num4]; // NOTIFY

  // Updating the item, emits an event to all `num1` consumers
  final item = numberList.value[0];
  item.value = 200; // NOTIFY
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
    // Update the list
    // => Triggers MyUserList > build > EventualBuilder > builder()
    userList.error = err.toString();
  });

  runApp(MaterialApp(
    title: 'Eventual',
    home: Scaffold(
      appBar: AppBar(title: Text('Eventual')),
      body: MyUserList(userList),
    ),
  ));
}

class MyUserList extends StatelessWidget {
  final EventualNotifier<List<EventualNotifier<String>>> userList;

  MyUserList(this.userList);
  
  @override
  Widget build(BuildContext context) {
    // Consume the outer notifier (the list)
    return EventualBuilder(
      notifier: userList,
      builder: (context, _, __) {
        // When `userList` is updated, this builder reruns
        
        // Is the list still loading?
        if (userList.loading)
          return Text(userList.loadingMessage ?? "Loading users...");
        
        // Does it have an error?
        if (userList.hasError)
          return Text(userList.errorMessage);
        else if (!userList.hasValue)
          return Text("There are no users yet");
        
        // All good, use the list value
        final List<EventualNotifier<String>> items = userList.value;

        // Build individual children
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext ctx, int index) => MyUserCard(items[index]),
        );
      });
  }
}

class MyUserCard extends StatelessWidget {
  final EventualNotifier<String> userName;

  MyUserCard(this.userName);
  
  @override
  Widget build(BuildContext context) {
    // Consume an inner notifier
    return EventualBuilder(
      notifier: userName,
      builder: (context, _, __) {
        // When `userList[index]` or `userName` is updated, this builder reruns
        
        // Is the item loading?
        if (userName.loading) return Text(userName.loadingMessage ?? "Loading user name...");
        
        // Does the item have an error?
        if (userName.hasError) return Text(userName.errorMessage);
        else if (!userName.hasValue) return Text("The user has no name yet");
        
        // All good, use the list value
        final EventualNotifier<String> name = userName.value;
        return InkWell(
          child: Text("I am $name"),
          onTap: () {
            // Update the user value
            userName.loading = "This is a fake loading request";
            userName.setError = "Something wrong happened";
            // ...
            userName.value = "I have been tapped";
          }
        );
      }
    });
  }
}
```

This approach allows to efficiently update only the widgets that are using a certain part of the data. If the whole list changes, then `MyUserList > ListView.builder()` will rebuild a few rows. But if we only change an inner item, then only the affected instance of `MyUserCard` will rebuild.

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
- The "eventual" version calls `build()` just once and `build()Counter` when needed
- One class vs two classes for one Widget

## EventualNotifier getters

```dart
void main() {
  final someScore = EventualNotifier<int>(110);
  
  // The raw value or `null`
  print(someScore.value);
  
  // Whether a non-null value is set
  print(someScore.hasValue);
  
  // Whether the value is set to be loading
  print(someScore.isLoading);
  
  // Whether loading was called up to 10 seconds ago
  // Customizable, see below
  print(someScore.isLoadingFresh);
  
  // An optional message about what is being loaded or null
  print(someScore.loadingMessage);
  
  // Whether an error is set
  print(someScore.hasError);
  
  // The message of the last error
  print(someScore.errorMessage);
  
  // DateTime when the value was set
  print(someScore.lastUpdated);
  
  // DateTime when the error was set
  print(someScore.lastError);
  
  // Whether the value was set 10 or more seconds ago
  // Customizable, see below
  print(someScore.isFresh);

  // Modifiers

  final someName = EventualNotifier<String>("hello")
    // Consider the value obsolete after 60 seconds
    .withFreshnessTimeout(seconds: 60)
    // Consider the loading stale after 5 seconds
    .withLoadingTimeout(seconds: 5);
  
  // Whether the value was set 10 or more seconds ago
  // Customizable, see below
  print(someName.isFresh);

  // Whether loading was called up to 10 seconds ago
  // Customizable, see below
  print(someName.isLoadingFresh);
  
  final someDate = EventualNotifier<DateTime>()
    .withFreshnessTimeout(seconds: 1)
    .withLoadingTimeout(milliseconds: 50)
    .setError("No date yet")
    .setToLoading("Determining the current date")
    .setValue(DateTime.now());
  
  print(someDate.value);  // DateTime(...)
}
```

## Misc

Eventual is inspired on the core concepts behind [Option](https://doc.rust-lang.org/rust-by-example/std/option.html) and [Result](https://doc.rust-lang.org/rust-by-example/std/result.html) from [Rust](https://www.rust-lang.org/);

It also extends many concepts from `ValueNotifier<T>` in [Flutter](https://flutter.dev).
