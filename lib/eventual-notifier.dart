import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:eventual/eventual-value.dart';

/// Extends EventualValue, so that subscribed Widgets can rebuild
/// upon changes on the current value, error events or loading status
class EventualNotifier<T> extends EventualValue<T> with ChangeNotifier {
  /// Initializes the state with no value by default. If an argument is passed,
  /// the argument is set as the initial value.
  EventualNotifier([T? initialValue]) : super(initialValue);

  /// By default `isFresh` returns `false` 10 seconds after the value is set.
  /// Alter the recency threshold with a new value.
  /// Returns itself so further methods can be chained right after.
  @override
  EventualNotifier<T> withFreshnessTimeout(Duration duration) {
    super.withFreshnessTimeout(duration);
    return this;
  }

  /// By default `isLoadingFresh` returns `true` 10 seconds after `loading` is set to `true`.
  /// This method alters the timeout threshold with a new value.
  /// Returns itself so further methods can be chained right after.
  @override
  EventualNotifier<T> withLoadingTimeout(Duration duration) {
    super.withLoadingTimeout(duration);
    return this;
  }

  /// Sets the loading flag to true, an optional loading message and clears the error status.
  /// Returns itself so further methods can be chained right after.
  @override
  EventualNotifier<T> setToLoading([String? loadingMessage]) {
    super.setToLoading(loadingMessage);

    // Notify after the state is changed
    this._notifyChange();
    return this;
  }

  /// Sets the error message to the given value and toggles loading to false.
  /// Optionally, allows to keep the current value, even if there is an error.
  /// Returns itself so further methods can be chained right after.
  @override
  EventualNotifier<T> setError(String error, {bool keepPreviousValue = true}) {
    super.setError(error, keepPreviousValue: keepPreviousValue);

    // Notify after the state is changed
    this._notifyChange();
    return this;
  }

  /// Sets the underlying value, clears the error status,
  /// tracks the update time and sets the loading flag to false.
  /// Returns `this` so further methods can be chained right after.
  @override
  EventualNotifier<T> setValue(T? newValue) {
    super.setValue(newValue);

    // Notify after the state is changed
    this._notifyChange();
    return this;
  }

  /// Sets a default `value` **only if the object has just been created** and no updates have been performed on it.
  /// Use this method if you want to set a default value on an immutable EventualValue created elsewhere.
  /// This is the same as invoking `final myValue = EventualValue<int>(defaultValue);`.
  /// Returns `this` so further methods can be chained right after.
  @override
  EventualNotifier<T> setDefaultValue(T defaultValue) {
    super.setDefaultValue(defaultValue);
    return this;
  }

  /// Explicitly emits a change notification to the listeners
  EventualNotifier<T> notifyChange() {
    _notifyChange();
    return this;
  }

  _notifyChange([int retries = 5]) {
    assert(retries is int);
    try {
      this.notifyListeners();
    } catch (err) {
      // If it failed because a build was already in progress, wait and retry
      Timer(Duration(milliseconds: 5),
          () => retries > 0 ? this._notifyChange(retries - 1) : null);
    }
  }
}
