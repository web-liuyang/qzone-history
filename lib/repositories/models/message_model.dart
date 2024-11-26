import 'package:flutter/widgets.dart';
import '../entities/entities.dart';

class MessageModel extends ChangeNotifier {
  MessageModel([List<Message> messages = const []]) : _messages = messages;

  List<Message> _messages;

  List<Message> get messages => _messages;

  set messages(List<Message> value) {
    if (value == _messages) return;
    _messages = value;
    notifyListeners();
  }
}
