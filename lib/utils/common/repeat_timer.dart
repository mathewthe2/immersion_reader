import 'dart:async';

Future<Timer> repeatTimer(
    {required Duration frequency,
    required Duration timeout,
    required Function(Timer timer) callback,
    bool fireOnce = false,
    Function? timeoutCallback}) async {
  final timer = Timer.periodic(frequency, (timer) {
    callback(timer);
    if (fireOnce) {
      timer.cancel();
    }
  });
  Future.delayed(timeout, () {
    if (timer.isActive) {
      timer.cancel();
      if (timeoutCallback != null) {
        timeoutCallback();
      }
    }
  });
  return timer;
}
