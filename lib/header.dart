import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qzone/dialogs/dialogs.dart';
import 'package:qzone/repositories/models/user_model.dart';
import 'package:qzone/services/services.dart';

import 'repositories/entities/entities.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    final LoginUserModel userModel = context.watch<LoginUserModel>();
    final LoginService loginService = context.read<LoginService>();
    final User? user = userModel.user;

    return user != null
        ? Login(
            user: user,
            onLogout: loginService.logout,
          )
        : const NotLogin();
  }
}

class NotLogin extends StatelessWidget {
  const NotLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.account_circle, size: 48),
      title: Text("点击扫码登陆"),
      onTap: () => showLoginDialog(context),
    );
  }
}

class Login extends StatelessWidget {
  const Login({super.key, required this.user, required this.onLogout});

  final User user;

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipPath(
        clipper: const ShapeBorderClipper(shape: CircleBorder()),
        child: Image.network(
          user.avatar,
          width: 48,
          height: 48,
          errorBuilder:(context, error, stackTrace) {
            return Icon(Icons.person);
          },
        ),
      ),
      title: Text(user.nickname),
      subtitle: Text("QQ: ${user.qq}"),
      trailing: TextButton(
        onPressed: onLogout,
        child: Text("退出登录"),
      ),
    );
  }
}
