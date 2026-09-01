import 'package:flutter/foundation.dart';

class QueueProvider extends ChangeNotifier {
  int _position = 4;
  int _currentServing = 1;
  int _estimatedWaitMinutes = 18;

  int get position => _position;
  int get currentServing => _currentServing;
  int get estimatedWaitMinutes => _estimatedWaitMinutes;

  void decrementPosition() {
    _position = (_position - 1).clamp(1, 12);
    if (_position == 1) {
      _currentServing = 1;
      _estimatedWaitMinutes = 0;
    } else {
      _estimatedWaitMinutes = _position * 7;
    }
    notifyListeners();
  }

  void callNextPatient() {
    _position = (_position - 1).clamp(1, 12);
    if (_position == 1) {
      _estimatedWaitMinutes = 0;
      _currentServing = 1;
    } else {
      _estimatedWaitMinutes = _position * 7;
    }
    notifyListeners();
  }

  void setPosition(int newPosition) {
    _position = newPosition.clamp(1, 12);
    if (_position == 1) {
      _estimatedWaitMinutes = 0;
      _currentServing = 1;
    } else {
      _estimatedWaitMinutes = _position * 7;
    }
    notifyListeners();
  }
}
