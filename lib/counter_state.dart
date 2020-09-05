import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_device.dart';

class CounterState with ChangeNotifier {
  // default Constructor - loads the latest saved-value from disk
  // CounterState() {
  //   _load();
  // }

  CounterState() {
  _myDevice = MyDevice()
    ..addListener(() {
      notifyListeners();
    });
  // start listening for DB data
  _listenForUpdates();
}

  // convenience, to avoid using this string-literal more then once
  // static const _sharedPrefsKey = 'counterState';

  // the location of the document containing our state data
  final _sharedCounterDoc =
      Firestore.instance.collection('counterApp').document('shared');
  // convenience, to avoid using these string-literals more than once
  static const _dbCounterValueField = 'counterValue';
  static const _dbDeviceNameField = 'deviceName';

  // the actual state is private (hence the leading "_")
  int _value;
  String _lastUpdatedByDevice;
  MyDevice _myDevice;

  // this allows us read-only access to the state, which
  // ensures modification of state is via public methods
  // we expose (in this case that means "increment" only)
  int get value => _value;
  String get lastUpdatedByDevice => _lastUpdatedByDevice;
  String get myDevice => _myDevice.name;

  // transient state - i.e. will not be stored when the app is not running
  // internal-only readiness- & error-status
  bool _isWaiting = true;
  bool _hasError = false;

  // read-only status indicators
  bool get isWaiting => _isWaiting || _myDevice.isWaiting;
  bool get hasError => _hasError;

  // how we modify state and notify consumers (e.g. the App UI)
  // void increment() {
  // _value += 1;
  // notify the consumer of this data that something has been
  // updated - thus avoiding and need for setState()
  // notifyListeners();
  // }

  // how we modift the state
  void increment() => _setValue(_value + 1);
  void reset() => _setValue(0);

  void _setValue(int newValue) {
    _value = newValue;
    _save();
  }

  // void _load() => _store(load: true);
  // void _save() => _store();

  // helper to do the actual storage-ralated tasks handles both
  // initial-load & save since they only differ by essentially 1 line
  // - getInt vs setInt
  // void _store({bool load = false}) async {
  //   _hasError = false;
  //   _isWaiting = true;
  //   notifyListeners();
  //   // artificial delay so we can see the UI changes
  //   await Future.delayed(Duration(milliseconds: 500));

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     if (load) {
  //       _value = prefs.getInt(_sharedPrefsKey) ?? 0;
  //     } else {
  //       // save
  //       // uncomment this to simulate an error-during-save
  //       // if (_value > 3) throw Exception("Artificial Error");
  //       await prefs.setInt(_sharedPrefsKey, _value);
  //     }
  //     _hasError = false;
  //   } catch (error) {
  //     _hasError = true;
  //   }
  //   _isWaiting = false;
  //   notifyListeners();
  // }

  //  save the updated _value to the DB
  void _save() async {
    _hasError = false;
    _isWaiting = true;
    notifyListeners();
    try {
      await _sharedCounterDoc.setData({
        _dbCounterValueField: _value,
        _dbDeviceNameField: myDevice,
      });
      _hasError = false;
    } catch (error) {
      _hasError = true;
    }
    _isWaiting = false;
    notifyListeners();
  }

  // how we receive data from the DB, and notify
  void _listenForUpdates() {
    // listen to the stream of updates (e.g. due to other devices)
    _sharedCounterDoc.snapshots().listen(
      (snapshot) {
        _isWaiting = false;
        if (!snapshot.exists) {
          _hasError = true;
          notifyListeners();
          return;
        }
        _hasError = false;
        // Don't trust what we receive
        // - convert to string, then try to extract a number
        final counterText =
            (snapshot.data[_dbCounterValueField] ?? 0).toString();
        // last resort to us 0
        _value = int.tryParse(counterText) ?? 0;
        _lastUpdatedByDevice =
            (snapshot.data[_dbDeviceNameField] ?? 'No device').toString();
        notifyListeners();
      },
      onError: (error) {
        _hasError = true;
        notifyListeners();
      },
    );
  }
}
