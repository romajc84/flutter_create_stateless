import 'package:flutter/material.dart';

class CounterState with ChangeNotifier {
  // the actual state is private (hence the leading "_")
  int _value = 0;

  // this allows us read-only access to the state, which
  // ensures modification of state is via public methods
  // we expose (in this case that means "increment" only)
  int get value => _value;

  // how we modify state and notify consumers (e.g. the App UI)
  void increment() {
    _value += 1;
    // notify the consumer of this data that something has been
    // updated - thus avoiding and need for setState()
    notifyListeners();
  }
}
