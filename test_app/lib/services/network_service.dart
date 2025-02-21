import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider =
    Provider<ConnectivityService>((ref) => ConnectivityService());

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStreamController =
      StreamController<bool>.broadcast();

  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isConnected = true;

  ConnectivityService() {
    _startMonitoring();
  }

  void _startMonitoring() {
    _checkInitialConnectivity();

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      bool isConnected =
          results.any((result) => result != ConnectivityResult.none);

      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        _connectionStreamController.add(isConnected);
        print("Connectivity Changed: $results");
      }
    });
  }

  Stream<bool> get onConnectivityChanged => _connectionStreamController.stream;

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    bool isConnected =
        results.any((result) => result != ConnectivityResult.none);
    _isConnected = isConnected;
    _connectionStreamController.add(isConnected);
    print("Initial Connectivity: $results");
  }

  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  bool isConnectedSync() => _isConnected;

  void dispose() {
    _subscription.cancel();
    _connectionStreamController.close();
  }
}
