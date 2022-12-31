import 'dart:async';

class Async<T> {
  final bool complete;
  final bool shouldLoad;
  final T? value;

  T? call() => value;

  const Async(this.complete, this.shouldLoad, this.value);
}

// ignore: constant_identifier_names
const Uninitialized = Async<Never>(false, true, null);

class Loading<T> extends Async<T> {
  Loading(T? value) : super(false, false, value);
}

class Success<T> extends Async<T> {
  Success(T value) : super(true, false, value);
}

class Fail<T> extends Async<T> {
  final Error error;

  Fail(this.error) : super(true, true, null);
}

extension AsyncFuture<T> on Future<T> {
  StreamSubscription execute(void Function(Async<T> async) onAsync,
      {T? retainValue}) {
    onAsync(Loading(retainValue));
    return asStream().listen((event) {
      onAsync(Success(event));
    }, onError: (error) {
      onAsync(Fail(error));
    });
  }
}
