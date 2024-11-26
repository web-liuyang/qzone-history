import 'package:flutter/widgets.dart';
import '../entities/entities.dart';

class LoginUserModel extends ChangeNotifier {
  LoginUserModel(LoginUser? user) : _user = user;

  LoginUser? _user;

  LoginUser? get user => _user;

  set user(LoginUser? value) {
    if (value == _user) return;
    _user = value;
    notifyListeners();
  }
}
