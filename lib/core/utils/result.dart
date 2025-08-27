/// Result pattern implementation for error handling
/// 
/// This implementation provides a type-safe way to handle operations that
/// can either succeed with a value or fail with an error. It helps avoid
/// throwing exceptions and makes error handling explicit and composable.

/// Base Result class that represents either a success or failure
sealed class Result<T> {
  const Result();
  
  /// Creates a successful result with the given value
  const factory Result.success(T value) = Success<T>;
  
  /// Creates a failed result with the given error
  const factory Result.failure(Object error, [StackTrace? stackTrace]) = Failure<T>;
  
  /// Returns true if this result represents a successful operation
  bool get isSuccess => this is Success<T>;
  
  /// Returns true if this result represents a failed operation
  bool get isFailure => this is Failure<T>;
  
  /// Returns the success value or null if this is a failure
  T? get valueOrNull => switch (this) {
    Success<T>(value: final value) => value,
    Failure<T>() => null,
  };
  
  /// Returns the error or null if this is a success
  Object? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(error: final error) => error,
  };
  
  /// Returns the stack trace or null if this is a success or has no stack trace
  StackTrace? get stackTraceOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(stackTrace: final stackTrace) => stackTrace,
  };
  
  /// Returns the success value or throws the error if this is a failure
  T get value => switch (this) {
    Success<T>(value: final value) => value,
    Failure<T>(error: final error, stackTrace: final stackTrace) => 
      Error.throwWithStackTrace(error, stackTrace ?? StackTrace.current),
  };
  
  /// Returns the success value or the provided default value if this is a failure
  T getOrElse(T defaultValue) => switch (this) {
    Success<T>(value: final value) => value,
    Failure<T>() => defaultValue,
  };
  
  /// Returns the success value or the result of calling the provided function
  T getOrElseGet(T Function(Object error) defaultValue) => switch (this) {
    Success<T>(value: final value) => value,
    Failure<T>(error: final error) => defaultValue(error),
  };
  
  /// Transforms the success value using the provided function
  Result<U> map<U>(U Function(T value) transform) => switch (this) {
    Success<T>(value: final value) => Result.success(transform(value)),
    Failure<T>(error: final error, stackTrace: final stackTrace) => 
      Result.failure(error, stackTrace),
  };
  
  /// Transforms the error using the provided function
  Result<T> mapError(Object Function(Object error) transform) => switch (this) {
    Success<T>() => this,
    Failure<T>(error: final error, stackTrace: final stackTrace) => 
      Result.failure(transform(error), stackTrace),
  };
  
  /// Flat maps the success value using the provided function
  Result<U> flatMap<U>(Result<U> Function(T value) transform) => switch (this) {
    Success<T>(value: final value) => transform(value),
    Failure<T>(error: final error, stackTrace: final stackTrace) => 
      Result.failure(error, stackTrace),
  };
  
  /// Executes the appropriate function based on whether this is a success or failure
  U fold<U>(
    U Function(T value) onSuccess,
    U Function(Object error, StackTrace? stackTrace) onFailure,
  ) => switch (this) {
    Success<T>(value: final value) => onSuccess(value),
    Failure<T>(error: final error, stackTrace: final stackTrace) => 
      onFailure(error, stackTrace),
  };
  
  /// Executes the provided function if this is a success
  Result<T> onSuccess(void Function(T value) action) {
    if (this case Success<T>(value: final value)) {
      action(value);
    }
    return this;
  }
  
  /// Executes the provided function if this is a failure
  Result<T> onFailure(void Function(Object error, StackTrace? stackTrace) action) {
    if (this case Failure<T>(error: final error, stackTrace: final stackTrace)) {
      action(error, stackTrace);
    }
    return this;
  }
  
  /// Executes the provided function regardless of success or failure
  Result<T> onComplete(void Function(Result<T> result) action) {
    action(this);
    return this;
  }
  
  /// Recovers from failure by providing an alternative value
  Result<T> recover(T Function(Object error) recovery) => switch (this) {
    Success<T>() => this,
    Failure<T>(error: final error) => Result.success(recovery(error)),
  };
  
  /// Recovers from failure by providing an alternative Result
  Result<T> recoverWith(Result<T> Function(Object error) recovery) => switch (this) {
    Success<T>() => this,
    Failure<T>(error: final error) => recovery(error),
  };
  
  /// Filters the success value using the provided predicate
  Result<T> filter(bool Function(T value) predicate, [Object? error]) => switch (this) {
    Success<T>(value: final value) when predicate(value) => this,
    Success<T>() => Result.failure(error ?? 'Filter predicate failed'),
    Failure<T>() => this,
  };
  
  @override
  String toString() => switch (this) {
    Success<T>(value: final value) => 'Success($value)',
    Failure<T>(error: final error) => 'Failure($error)',
  };
  
  @override
  bool operator ==(Object other) => switch (this) {
    Success<T>(value: final value) => 
      other is Success<T> && value == other.value,
    Failure<T>(error: final error) => 
      other is Failure<T> && error == other.error,
  };
  
  @override
  int get hashCode => switch (this) {
    Success<T>(value: final value) => value.hashCode,
    Failure<T>(error: final error) => error.hashCode,
  };
}

/// Represents a successful result with a value
final class Success<T> extends Result<T> {
  const Success(this.value);
  
  final T value;
}

/// Represents a failed result with an error and optional stack trace
final class Failure<T> extends Result<T> {
  const Failure(this.error, [this.stackTrace]);
  
  final Object error;
  final StackTrace? stackTrace;
}

/// Extension methods for working with Results
extension ResultExtensions<T> on Result<T> {
  /// Converts this Result to a nullable value
  T? toNullable() => valueOrNull;
  
  /// Converts this Result to a List containing the value if successful, empty if failure
  List<T> toList() => switch (this) {
    Success<T>(value: final value) => [value],
    Failure<T>() => [],
  };
  
  /// Converts this Result to an Iterable
  Iterable<T> toIterable() => toList();
}

/// Extension methods for nullable values to convert to Results
extension NullableToResult<T extends Object> on T? {
  /// Converts a nullable value to a Result
  Result<T> toResult([Object? error]) => this != null 
    ? Result.success(this!)
    : Result.failure(error ?? 'Value is null');
}

/// Utility functions for working with Results
abstract class Results {
  /// Executes an async operation and wraps the result in a Result
  static Future<Result<T>> tryAsync<T>(Future<T> Function() operation) async {
    try {
      final value = await operation();
      return Result.success(value);
    } catch (error, stackTrace) {
      return Result.failure(error, stackTrace);
    }
  }
  
  /// Executes a synchronous operation and wraps the result in a Result
  static Result<T> trySync<T>(T Function() operation) {
    try {
      final value = operation();
      return Result.success(value);
    } catch (error, stackTrace) {
      return Result.failure(error, stackTrace);
    }
  }
  
  /// Combines multiple Results into a single Result
  /// Returns success only if all Results are successful
  static Result<List<T>> combine<T>(Iterable<Result<T>> results) {
    final values = <T>[];
    
    for (final result in results) {
      switch (result) {
        case Success<T>(value: final value):
          values.add(value);
        case Failure<T>() as final failure:
          return Result.failure(failure.error, failure.stackTrace);
      }
    }
    
    return Result.success(values);
  }
  
  /// Returns the first successful Result, or the last failure if none succeed
  static Result<T> firstSuccess<T>(Iterable<Result<T>> results) {
    Failure<T>? lastFailure;
    
    for (final result in results) {
      switch (result) {
        case Success<T>():
          return result;
        case Failure<T>() as final failure:
          lastFailure = failure;
      }
    }
    
    return lastFailure ?? const Result.failure('No results provided');
  }
  
  /// Partitions a list of Results into successes and failures
  static (List<T>, List<Object>) partition<T>(Iterable<Result<T>> results) {
    final successes = <T>[];
    final failures = <Object>[];
    
    for (final result in results) {
      switch (result) {
        case Success<T>(value: final value):
          successes.add(value);
        case Failure<T>(error: final error):
          failures.add(error);
      }
    }
    
    return (successes, failures);
  }
  
  /// Filters Results to only include successes
  static Iterable<T> successes<T>(Iterable<Result<T>> results) {
    return results
        .where((result) => result.isSuccess)
        .map((result) => result.value);
  }
  
  /// Filters Results to only include failures
  static Iterable<Object> failures<T>(Iterable<Result<T>> results) {
    return results
        .where((result) => result.isFailure)
        .map((result) => result.errorOrNull!)
        .cast<Object>();
  }
}

/// A specialized Result for operations that don't return a value
typedef VoidResult = Result<void>;

/// Extension for creating void results
extension VoidResultExtensions on VoidResult {
  /// Creates a successful void result
  static VoidResult success() => const Result.success(null);
  
  /// Creates a failed void result
  static VoidResult failure(Object error, [StackTrace? stackTrace]) => 
    Result.failure(error, stackTrace);
}

/// Utility for creating void results
abstract class VoidResults {
  /// Creates a successful void result
  static VoidResult success() => const Result.success(null);
  
  /// Creates a failed void result
  static VoidResult failure(Object error, [StackTrace? stackTrace]) => 
    Result.failure(error, stackTrace);
  
  /// Executes an async void operation and wraps it in a VoidResult
  static Future<VoidResult> tryAsync(Future<void> Function() operation) async {
    try {
      await operation();
      return success();
    } catch (error, stackTrace) {
      return failure(error, stackTrace);
    }
  }
  
  /// Executes a synchronous void operation and wraps it in a VoidResult
  static VoidResult trySync(void Function() operation) {
    try {
      operation();
      return success();
    } catch (error, stackTrace) {
      return failure(error, stackTrace);
    }
  }
}