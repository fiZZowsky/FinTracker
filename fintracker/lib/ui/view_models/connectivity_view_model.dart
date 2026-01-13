import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConnectivityViewModel extends ChangeNotifier {
  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityViewModel() {
    _initConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } on PlatformException catch (e) {
      debugPrint('Nie udało się sprawdzić stanu sieci: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasNet = !results.contains(ConnectivityResult.none);

    if (_hasInternet != hasNet) {
      _hasInternet = hasNet;
      notifyListeners();
    }
  }

  Future<void> checkConnection() async {
    await _initConnectivity();
  }

  void exitApp() {
    SystemNavigator.pop();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
