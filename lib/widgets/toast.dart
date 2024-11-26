import 'package:flutter/widgets.dart';
import 'package:qzone/layout.dart';
import 'package:toastification/toastification.dart';

class Toast {
  static void success(String message) {
    toastification.show(
      title: Text(message),
      type: ToastificationType.success,
      // autoCloseDuration: const Duration(seconds: 3),
      dragToClose: true,
      showProgressBar: false,
    );
  }

  static void error(String message) {
    toastification.show(
      title: Text(message),
      type: ToastificationType.error,
      // autoCloseDuration: const Duration(seconds: 3),
      dragToClose: true,
      showProgressBar: false,
    );
  }

  static void info(String message) {
    toastification.show(
      title: Text(message),
      type: ToastificationType.info,
      // autoCloseDuration: const Duration(seconds: 3),
      dragToClose: true,
      showProgressBar: false,
    );
  }

  static ToastAction loading(String message) {
    final OverlayState overlayState = Overlay.of(rootContext, rootOverlay: true);
    // final el = overlayState.context as Element;

    final GlobalKey<ToastTitleState> titleKey = GlobalKey();

    final item = toastification.show(
      overlayState: overlayState,
      title: ToastTitle(
        key: titleKey,
        title: Text(message),
      ),
      type: ToastificationType.info,
      dragToClose: false,
      closeOnClick: true,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.none,
    );

    return ToastAction(item: item, titleKey: titleKey);
  }
}

class ToastTitle extends StatefulWidget {
  const ToastTitle({super.key, required this.title});

  final Widget title;

  @override
  State<ToastTitle> createState() => ToastTitleState();
}

class ToastTitleState extends State<ToastTitle> {
  late Widget _title = widget.title;

  set title(Widget title) {
    setState(() => _title = title);
  }

  @override
  Widget build(BuildContext context) {
    return _title;
  }
}

class ToastAction {
  ToastAction({required this.titleKey, required this.item});

  final GlobalKey<ToastTitleState> titleKey;

  final ToastificationItem item;

  void update(String message) {
    final state = titleKey.currentState;

    if (state == null) return;
    if (state._title is Text && (state._title as Text).data == message) return;

    state.title = Text(message);
  }

  void dismiss() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   toastification.dismiss(item);
    // });
    toastification.dismiss(item);
  }
}
