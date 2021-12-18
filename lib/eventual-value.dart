/// `EventualValue<T>` wraps and manages **eventual data**, which can be still unresolved,
/// have an error, or have a non-null valid value.
///
/// Use this class if you need to track eventual data, and be able to check its status explicitly
/// from your code using `hasValue`, `hasError` and `isLoading`.
///
class EventualValue<T> {
  // The very value being tracked
  T? _value;
  // The last time the value was set
  DateTime? _valueUpdated;

  // Date when the loading state was set. Null => not loading.
  DateTime? _loadingStartTimestamp;
  // Optional message
  String? _loadingMessage;

  // Date when the error state was set. Null => no error.
  DateTime? _errorTimestamp;
  // Error message
  String? _errorMessage;

  // Amount of milliseconds before `isFresh` starts returning false
  int _valueFreshnessTimeout = 10 * 1000;
  // Amount of milliseconds before `isLoadingFresh` starts returning true
  int _loadingFreshnessTimeout = 10 * 1000;

  /// Initializes the state with no value by default. If an argument is passed,
  /// the argument is set as the initial value.
  EventualValue([T? initialValue]) {
    if (initialValue is T) {
      _value = initialValue;
    }
  }

  /// By default `isFresh` returns `false` 10 seconds after the value is set.
  /// Alter the recency threshold with a new value.
  /// Returns itself so further methods can be chained right after.
  EventualValue<T> withFreshnessTimeout(Duration duration) {
    assert(!duration.isNegative, "The duration must be positive");
    this._valueFreshnessTimeout = duration.inMilliseconds;

    return this;
  }

  /// By default `isLoadingFresh` returns `true` 10 seconds after `loading` is set to `true`.
  /// This method alters the timeout threshold with a new value.
  /// Returns itself so further methods can be chained right after.
  EventualValue<T> withLoadingTimeout(Duration duration) {
    assert(!duration.isNegative, "The duration must be positive");
    this._loadingFreshnessTimeout = duration.inMilliseconds;

    return this;
  }

  // LOADING STATUS HANDLERS

  /// Returns `true` if the loading flag is currently active
  bool get isLoading => _loadingStartTimestamp != null;

  /// Returns the optional loading message string
  String? get loadingMessage => _loadingMessage;

  /// Returns `true` if `setToLoading()` was recently called (by default, 10 seconds).
  /// Returns `false` if `setToLoading()` was called more than X seconds ago or the value is simply not "loading".
  bool get isLoadingFresh {
    if (!isLoading) return false;

    final stallThreshold = _loadingStartTimestamp!.add(Duration(
        milliseconds:
            _loadingFreshnessTimeout)); // loading date + N milliseconds
    return DateTime.now().isBefore(stallThreshold);
  }

  /// Sets `loading = true` and sets the loading message
  set loadingMessage(String? message) {
    if (_loadingMessage != message || !this.isLoading)
      this.setToLoading(message);
  }

  /// Sets or unsets the loading flag.
  set loading(bool loadingValue) {
    if (_value == loadingValue)
      return;
    else if (loadingValue)
      this.setToLoading();
    else {
      _loadingStartTimestamp = null;
      _loadingMessage = null;
    }
  }

  /// Sets the loading flag to true, an optional loading message and clears the error status.
  /// Returns itself so further methods can be chained right after.
  EventualValue<T> setToLoading([String? loadingMessage]) {
    _loadingStartTimestamp = DateTime.now();
    if (loadingMessage is String && loadingMessage.length > 0) {
      _loadingMessage = loadingMessage;
    }

    _errorMessage = null;
    _errorTimestamp = null;
    return this;
  }

  // ERROR STATUS HANDLERS

  /// Returns true if an error message is currently set
  bool get hasError => _errorTimestamp != null;

  /// Returns the last error message defined
  String? get errorMessage => _errorMessage;

  /// Returns the timestamp when the last error was set
  DateTime? get lastError => _errorTimestamp;

  /// Syntactic sugar for `setError(message)`
  set error(String message) {
    if (_errorMessage != message || !this.hasError || this.isLoading) {
      this.setError(message);
    }
  }

  /// Sets the error message to the given value and toggles loading to false.
  /// Optionally, allows to keep the current value, even if there is an error.
  /// Returns itself so further methods can be chained right after.
  EventualValue<T> setError(String message, {bool keepPreviousValue = true}) {
    _errorMessage = message;
    _errorTimestamp = DateTime.now();

    _loadingMessage = null;
    _loadingStartTimestamp = null;

    if (keepPreviousValue != true) {
      _value = null;
      _valueUpdated = null;
    }
    return this;
  }

  // VALUE STATUS HANDLERS

  /// Provides the current value, if there is any
  T? get value => _value;

  /// Returns true if a valid value is registered and no error has
  /// cleared it
  bool get hasValue => _value is T;

  /// Returns the last successful update
  DateTime? get lastUpdated => _valueUpdated;

  /// Sysntactic sugar for `setValue(newValue)`
  set value(T? newValue) {
    this.setValue(newValue);
  }

  /// Sets the underlying value, clears the error status,
  /// tracks the update time and sets the loading flag to false.
  /// Returns `this` so further methods can be chained right after.
  EventualValue<T> setValue(T? newValue) {
    if (_value == newValue && !this.isLoading && !this.hasError) return this;

    _value = newValue;
    _valueUpdated = DateTime.now();

    _loadingStartTimestamp = null;
    _loadingMessage = null;

    _errorMessage = null;
    _errorTimestamp = null;
    return this;
  }

  /// Sets a default `value` **only if the object has just been created** and no updates have been performed on it.
  /// Use this method if you want to set a default value on an immutable EventualValue created elsewhere.
  /// This is the same as invoking `final myValue = EventualValue<int>(defaultValue);`.
  /// Returns `this` so further methods can be chained right after.
  EventualValue<T> setDefaultValue(T defaultValue) {
    if (hasValue || isLoading || hasError || lastUpdated != null)
      throw Exception(
          "The default value can't be set once the object has been updated. Use setValue() instead.");
    _value = defaultValue;
    return this;
  }

  /// Returns `true` only if a valid value was set less than N seconds ago
  bool get isFresh {
    if (!hasValue || _valueUpdated is! DateTime) return false;

    final freshThreshold = _valueUpdated!.add(Duration(
        milliseconds: _valueFreshnessTimeout)); // update date + N milliseconds
    return DateTime.now().isBefore(freshThreshold);
  }

  @override
  String toString() => '${this.runtimeType}($value,$isLoading,$errorMessage)';
}
