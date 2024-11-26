import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

typedef ThreadCallback<T> = FutureOr<void> Function(ValueSetter<T> send);

typedef ThreadEvent<T> = void Function(T message);

typedef P<T> = (ValueSetter<T> send, ThreadCallback<T> cb);

class ThreadAction {
  const ThreadAction({
    required this.close,
  });

  final VoidCallback close;
}

class _SpawnArgs<T> {
  const _SpawnArgs({
    required this.sendPort,
    required this.executor,
  });

  final SendPort sendPort;

  final ThreadCallback<T> executor;
}

enum ThreadState {
  running,
  done,
}

class Thread {
  static Future<void> run<T>(
    ThreadCallback<T> executor, {
    ThreadEvent<T>? onEvent,
    VoidCallback? onDone,
  }) async {
    final ReceivePort receivePort = ReceivePort();
    late final Isolate isolate;

    void entryPoint(_SpawnArgs data) async {
      await data.executor((v) {
        data.sendPort.send(v);
      });

      data.sendPort.send(ThreadState.done);
    }

    isolate = await Isolate.spawn(
      entryPoint,
      _SpawnArgs(executor: executor, sendPort: receivePort.sendPort),
    );

    if (onEvent != null) {
      receivePort.listen(
        (message) {
          if (message is ThreadState && message == ThreadState.done) {
            receivePort.close();
            isolate.kill();
          } else {
            onEvent(message);
          }
        },
        onDone: () {
          onDone?.call();
        },
      );
    }
  }
}
