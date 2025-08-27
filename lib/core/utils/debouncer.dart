import 'dart:async';

/// Memory-safe debouncing utility
/// 
/// This class provides a debouncing mechanism that helps prevent excessive
/// function calls by delaying execution until after a specified duration
/// has passed without any new calls. It's particularly useful for search
/// inputs, button clicks, and API calls.
class Debouncer {
  final Duration delay;
  Timer? _timer;
  bool _isDisposed = false;
  
  /// Creates a debouncer with the specified delay duration
  Debouncer({required this.delay});
  
  /// Debounces the execution of the provided action
  /// 
  /// [action] - The function to execute after the delay
  /// 
  /// If called multiple times within the delay period, only the last
  /// call will be executed after the delay expires.
  void call(VoidCallback action) {
    if (_isDisposed) return;
    
    // Cancel the previous timer if it exists
    _timer?.cancel();
    
    // Create a new timer with the specified delay
    _timer = Timer(delay, () {
      if (!_isDisposed) {
        action();
      }
    });
  }
  
  /// Executes the action immediately and cancels any pending execution
  /// 
  /// [action] - The function to execute immediately
  void immediate(VoidCallback action) {
    if (_isDisposed) return;
    
    _timer?.cancel();
    action();
  }
  
  /// Cancels any pending execution without calling the action
  void cancel() {
    _timer?.cancel();
  }
  
  /// Checks if there's a pending execution
  bool get isActive => _timer?.isActive ?? false;
  
  /// Disposes of the debouncer and cancels any pending timers
  /// 
  /// After calling dispose, this debouncer instance should not be used.
  /// This is important for memory management and preventing memory leaks.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _isDisposed = true;
  }
}

/// A specialized debouncer for search operations
/// 
/// This extends the basic debouncer with additional features commonly
/// needed for search functionality, such as minimum query length and
/// empty query handling.
class SearchDebouncer extends Debouncer {
  final int minimumQueryLength;
  final bool allowEmptyQuery;
  
  /// Creates a search debouncer with search-specific options
  /// 
  /// [delay] - The debounce delay duration
  /// [minimumQueryLength] - Minimum characters required before triggering search
  /// [allowEmptyQuery] - Whether to allow empty search queries
  SearchDebouncer({
    required super.delay,
    this.minimumQueryLength = 2,
    this.allowEmptyQuery = false,
  });
  
  /// Debounces a search action with query validation
  /// 
  /// [query] - The search query string
  /// [action] - The search function to execute
  /// [onInvalidQuery] - Optional callback for invalid queries
  void search(
    String query, 
    ValueChanged<String> action, {
    VoidCallback? onInvalidQuery,
  }) {
    final trimmedQuery = query.trim();
    
    // Check if query meets minimum requirements
    if (!allowEmptyQuery && trimmedQuery.isEmpty) {
      cancel();
      onInvalidQuery?.call();
      return;
    }
    
    if (trimmedQuery.length < minimumQueryLength && trimmedQuery.isNotEmpty) {
      cancel();
      onInvalidQuery?.call();
      return;
    }
    
    // Debounce the search action
    call(() => action(trimmedQuery));
  }
}

/// A debouncer specifically designed for button press prevention
/// 
/// This helps prevent double-taps and rapid button pressing that could
/// lead to duplicate actions or API calls.
class ButtonDebouncer extends Debouncer {
  bool _isProcessing = false;
  
  /// Creates a button debouncer with a default delay suitable for button presses
  ButtonDebouncer({
    super.delay = const Duration(milliseconds: 1000),
  });
  
  /// Executes the action if not already processing
  /// 
  /// [action] - The async function to execute
  /// 
  /// Returns true if the action was executed, false if it was debounced.
  Future<bool> execute(Future<void> Function() action) async {
    if (_isDisposed || _isProcessing) return false;
    
    _isProcessing = true;
    
    try {
      await action();
      return true;
    } finally {
      if (!_isDisposed) {
        Timer(delay, () {
          _isProcessing = false;
        });
      }
    }
  }
  
  /// Checks if the debouncer is currently processing an action
  bool get isProcessing => _isProcessing;
  
  @override
  void dispose() {
    _isProcessing = false;
    super.dispose();
  }
}

/// A generic debouncer that can handle any type of value
/// 
/// This is useful for debouncing changes to form fields, sliders,
/// or any other input that produces values.
class ValueDebouncer<T> {
  final Duration delay;
  Timer? _timer;
  bool _isDisposed = false;
  T? _lastValue;
  
  /// Creates a value debouncer with the specified delay
  ValueDebouncer({required this.delay});
  
  /// Debounces value changes
  /// 
  /// [value] - The new value
  /// [action] - The function to execute with the debounced value
  /// [equalityCheck] - Optional custom equality check function
  void setValue(
    T value,
    ValueChanged<T> action, {
    bool Function(T oldValue, T newValue)? equalityCheck,
  }) {
    if (_isDisposed) return;
    
    // Use custom equality check or default comparison
    final areEqual = equalityCheck?.call(_lastValue as T, value) ?? 
                    (_lastValue == value);
    
    // Don't debounce if value hasn't changed
    if (_lastValue != null && areEqual) return;
    
    _lastValue = value;
    _timer?.cancel();
    
    _timer = Timer(delay, () {
      if (!_isDisposed) {
        action(value);
      }
    });
  }
  
  /// Gets the last value that was set
  T? get lastValue => _lastValue;
  
  /// Cancels any pending execution
  void cancel() {
    _timer?.cancel();
  }
  
  /// Checks if there's a pending execution
  bool get isActive => _timer?.isActive ?? false;
  
  /// Disposes of the debouncer
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _lastValue = null;
    _isDisposed = true;
  }
}

/// A utility class for managing multiple debouncers
/// 
/// This is useful when you have multiple debounced operations in a single
/// controller or widget and want to manage their lifecycle together.
class DebouncerManager {
  final Map<String, Debouncer> _debouncers = {};
  bool _isDisposed = false;
  
  /// Creates a new debouncer with the given key and delay
  /// 
  /// If a debouncer with the same key already exists, it will be disposed
  /// and replaced with the new one.
  Debouncer create(String key, Duration delay) {
    if (_isDisposed) {
      throw StateError('DebouncerManager has been disposed');
    }
    
    // Dispose existing debouncer if it exists
    _debouncers[key]?.dispose();
    
    final debouncer = Debouncer(delay: delay);
    _debouncers[key] = debouncer;
    return debouncer;
  }
  
  /// Gets an existing debouncer by key
  Debouncer? get(String key) => _debouncers[key];
  
  /// Executes a debounced action using the debouncer with the given key
  /// 
  /// If no debouncer exists with the key, one will be created with the
  /// provided delay.
  void execute(String key, Duration delay, VoidCallback action) {
    if (_isDisposed) return;
    
    final debouncer = _debouncers[key] ?? create(key, delay);
    debouncer(action);
  }
  
  /// Cancels all pending executions
  void cancelAll() {
    for (final debouncer in _debouncers.values) {
      debouncer.cancel();
    }
  }
  
  /// Removes and disposes a specific debouncer
  void remove(String key) {
    final debouncer = _debouncers.remove(key);
    debouncer?.dispose();
  }
  
  /// Gets the number of active debouncers
  int get activeCount => _debouncers.values.where((d) => d.isActive).length;
  
  /// Gets all debouncer keys
  List<String> get keys => _debouncers.keys.toList();
  
  /// Disposes all debouncers and clears the manager
  void dispose() {
    for (final debouncer in _debouncers.values) {
      debouncer.dispose();
    }
    _debouncers.clear();
    _isDisposed = true;
  }
}