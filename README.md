# eventual

Eventual provides a toolkit to manage **eventual values**, **notify** the UI when changes occur and **rebuild** the relevant widget subtree accordingly.

This package allows for great flexibility in complex scenarios while keeping the focus on clean and simple approach. 

## Getting Started

Check the [Installing tab](https://pub.dev/packages/event_bus#-installing-tab-), add `eventual` as a dependency on `pubspec.yaml` and import the package within your code.

The lifecycle revolves around 3 classes:
- `EventuaValue<T>`
    - Used to manage plain state
- `EventNotifier<T>`
    - Manage plain state and emit `Listenable` events upon change
- `EventualBuilder`
  - A Widget that rebuilds whenever the notifier(s) change(s)

Create your first `EventNotifier`:

```dart
export "package:eventual/eventual.dart";

void main() {
    // No value by default
    final someScore = EventNotifier<int>();
    print(someScore.value); // null

    // A default value
    final myScore = EventNotifier<int>(97);
    print(myScore.value); // 97

    // Set to loading, but keep the value
    myScore.loading = true;

    print(myScore.value); // 97
    print(myScore.isLoading); // true

    // Stop loading and set an error message while
    // the old value is still available
    myScore.error = "Something went wrong";

    print(myScore.value); // 97
    print(myScore.isLoading); // false
    print(myScore.hasError); // true
    print(myScore.errorMessage); // "Something went wrong"

    // Set to loading with an optional message
    myScore.loadingMessage = "Please, wait";

    print(myScore.value); // 97
    print(myScore.isLoading); // false
    print(myScore.loadingMessage); // "Please, wait"
    print(myScore.hasError); // false

    // Set a new value
    myScore.value = 110;
    
    // All the available status getters
    print(myScore.value); // 110
    print(myScore.hasValue); // true
    print(myScore.isLoading); // false
    print(myScore.isLoadingFresh); // false
    print(myScore.loadingMessage); // null
    print(myScore.hasError); // false
    print(myScore.errorMessage); // null
    print(myScore.lastUpdated); // DateTime(...)
    print(myScore.lastError); // null
    print(myScore.isFresh); // true
}
```

Consume the notifier on your Widget tree:

```dart
class MyWidget extends StatelessWidget {
    final EventualNotifier<String> userName;
    final EventualNotifier<int> userScore;

    const MyWidget(this.userName, this.userScore);

    @override
    initState() {
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

`EventualNotifier`'s can be consumed from a global repository or be created locally. In either case, the widget will update to reflect the latest version of the values.

## Collections

Working with collections of objects is as simple as using a `List<*>` as the actual `value`.

However, tracking the state of inner values raises performance concerns and gets out of the scope of an `EventualNotifier`.

```dart
export "package:eventual/eventual.dart";

void main() {
    final numberList = EventNotifier<List<int>>([]);
    print(numberList.value); // []

    // Setting a new list, emits an event
    numberList.value = [1, 2, 3, 4]; // => notifyListeners()
    print(numberList.value); // prints [1, 2, 3, 4]
    // EventualBuilder(builder: ...) would see [1, 2, 3, 4]

    // However, updating the list itself emits no event
    numberList.value.add(5); // => NO EVENT
    print(numberList.value); // prints [1, 2, 3, 4, 5]
    // EventualBuilder(builder: ...) still would see [1, 2, 3, 4]

    // To force a notification, we can call setValue()
    final tempList = numberList.value;
    tempList.add(5);
    numberList.setValue(tempList);
    print(numberList.value); // prints [1, 2, 3, 4, 5]
    // EventualBuilder(builder: ...) now would see [1, 2, 3, 4, 5]

    // Alternatively
    numberList.value.add(6);
    numberList.notifyChange();
    print(numberList.value); // prints [1, 2, 3, 4, 5, 6]
    // EventualBuilder(builder: ...) would also see [1, 2, 3, 4, 5, 6]
}
```

Is there a way to be notified when an item changes? Depper state can be managed by splitting `EventualNotifier`'s into layers.

In the example above, we could use a `List<EventualNotifiers<int>>` instead of a `List<int>`.

```dart
void main() {
    final numberList = EventNotifier<List<EventNotifier<int>>>([]);

    final num1 = EventNotifier<int>(10);
    final num2 = EventNotifier<int>();
    final num3 = EventNotifier<int>().setError("Invalid number");
    final num4 = EventNotifier<int>().setToLoading();

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
    final userList = EventNotifier<List<EventNotifier<String>>>();

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
    final EventNotifier<List<EventNotifier<String>>> userList;

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
                final List<EventNotifier<String>> items = userList.value;

                // Build individual children
                return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext ctx, int index) => MyUserCard(items[index]),
                );
            });
    }
}

class MyUserCard extends StatelessWidget {
    final EventNotifier<String> userName;

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
                final EventNotifier<String> name = userName.value;
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

## Misc

Eventual is inspired on the core concepts behind [Option](https://doc.rust-lang.org/rust-by-example/std/option.html) and [Result](https://doc.rust-lang.org/rust-by-example/std/result.html) from [Rust](https://www.rust-lang.org/);

It also extends many concepts from `ValueNotifier<T>` in [Flutter](https://flutter.dev).
