import 'package:flutter/material.dart';

class UFVAppState extends ChangeNotifier {
  String _current = 'Sample Item';
  final List<String> _savedItems = [];

  String get current => _current;
  List<String> get savedItems => List.unmodifiable(_savedItems);

  void getNext() {
    _current = 'New Item';
    notifyListeners();
  }

  void toggleSaved() {
    if (_savedItems.contains(_current)) {
      _savedItems.remove(_current);
    } else {
      _savedItems.add(_current);
    }
    notifyListeners();
  }
}