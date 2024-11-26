import 'package:flutter/widgets.dart';
import '../entities/entities.dart';

class MomentModel extends ChangeNotifier {
  MomentModel([List<Moment> moments = const []]) : _moments = moments;

  List<Moment> _moments;

  List<Moment> get moments => _moments;

  set moments(List<Moment> value) {
    if (value == _moments) return;
    _moments = value;
    notifyListeners();
  }
}
