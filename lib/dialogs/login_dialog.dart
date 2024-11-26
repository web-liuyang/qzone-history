import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qzone/requests/requests.dart';
import 'package:qzone/services/services.dart';
import 'package:qzone/utils/utils.dart';
import 'package:qzone/widgets/widgets.dart';

import 'dialog_layout.dart';
import 'show_effective_dialog.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  bool loadingQRCode = false;
  bool loadingUser = false;

  Cookie? cookie;
  Uint8List? qrcode;
  QRCodeStatus loginStatus = QRCodeStatus.waiting;

  Cookie? token;

  Timer? updateLoginQRCodeStatusTimer;

  @override
  void initState() {
    fetchLoginQRCode();
    super.initState();
  }

  @override
  void dispose() {
    updateLoginQRCodeStatusTimer?.cancel();
    super.dispose();
  }

  void fetchLoginQRCode() async {
    setState(() => loadingQRCode = true);
    final qrcodeRes = await requestLoginQRCode();
    final cookieStr = qrcodeRes.headers["set-cookie"]![0];
    setState(() {
      qrcode = qrcodeRes.data;
      cookie = Cookie.fromSetCookieValue(cookieStr);
      loadingQRCode = false;
      updateLoginQRCodeStatusTimer = Timer.periodic(const Duration(seconds: 2), (timer) => fetchLoginQRCodeStatus());
    });
  }

  void fetchLoginQRCodeStatus() async {
    final String qrsig = cookie!.value;
    final String token = "${ptqrToken(qrsig)}";
    final statusRes = await requestLoginQRCodeStatus(qrsig: qrsig, ptqrtoken: token);
    if (loginStatus != statusRes.data.status) setState(() => loginStatus = statusRes.data.status);

    if (statusRes.data.status == QRCodeStatus.expired) {
      updateLoginQRCodeStatusTimer?.cancel();
      return;
    }

    if (statusRes.data.status == QRCodeStatus.resolve) {
      updateLoginQRCodeStatusTimer?.cancel();

      final qq = statusRes.data.qq!;
      final ptsigx = statusRes.data.ptsigx!;
      final cookies = resolveCookiesFromArray(statusRes.headers["set-cookie"] ?? []);
      fetchUserToken(qq: qq, ptsigx: ptsigx, cookies: cookies);
    }
  }

  void fetchUserToken({required String qq, required String ptsigx, required List<Cookie> cookies}) async {
    setState(() => loadingUser = true);
    final userTokenRes = await requestUserToken(qq: qq, ptsigx: ptsigx, cookies: cookies);
    final gTk = "${bkn(userTokenRes.data.getValue("p_skey")!)}";
    final userRes = await requestLoginUser(gTk: gTk, qq: qq, cookies: userTokenRes.data);
    if (!mounted) return;

    setState(() => loadingUser = false);
    await context.read<LoginService>().login(userRes.data);
    widget.onClose();
  }

  String formatStatus(QRCodeStatus status) {
    return switch (status) {
      QRCodeStatus.expired => "已过期",
      QRCodeStatus.waiting => "等待扫码",
      QRCodeStatus.scanned => "认证中",
      QRCodeStatus.reject => "本次登录已被拒绝",
      QRCodeStatus.resolve => "登录成功",
    };
  }

  @override
  Widget build(BuildContext context) {
    return DialogLayout(
      content: SpacedWidget(
        children: [
          Text("请使用手机QQ扫码登录"),
          Container(
            width: 300,
            height: 300,
            child: loadingQRCode ? const CircularProgressIndicator() : Image.memory(qrcode!, fit: BoxFit.fill),
          ),
          Text("二维码状态：${formatStatus(loginStatus)}"),
          if (loadingUser) Text("正在加载用户信息"),
          TextButton(
            onPressed: fetchLoginQRCode,
            child: Text("重新获取二维码"),
          ),
        ],
      ),
      onClose: widget.onClose,
    );
  }
}

Future<void> showLoginDialog(BuildContext context) async {
  return showEffectiveDialog(
    context: context,
    useRootNavigator: false,
    builder: (ctx) {
      return LoginDialog(
        onClose: () => Navigator.of(ctx).pop(),
      );
    },
  );
}
