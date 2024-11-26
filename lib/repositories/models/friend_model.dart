import 'package:flutter/widgets.dart';
import '../entities/entities.dart';

class FriendModel extends ChangeNotifier {
  FriendModel([List<User> friends = const []]) : _friends = friends;

  List<User> _friends;

  List<User> get friends => _friends;

  set friends(List<User> value) {
    if (value == friends) return;
    _friends = value;
    notifyListeners();
  }
}
