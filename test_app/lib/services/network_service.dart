import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityServiceProvider =
    Provider<ConnectivityService>((ref) => ConnectivityService());

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStreamController =
      StreamController<bool>.broadcast(); // Allows multiple listeners

  late StreamSubscription<List<ConnectivityResult>>
      _subscription; // Handles list of results
  bool _isConnected = true; // Default to true

  ConnectivityService() {
    _startMonitoring();
  }

  void _startMonitoring() {
    _checkInitialConnectivity();

    // Monitor connectivity changes (handles a List<ConnectivityResult>)
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      bool isConnected =
          results.any((result) => result != ConnectivityResult.none);

      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        _connectionStreamController.add(isConnected);
        print("Connectivity Changed: $results"); // Logs the full list
      }
    });
  }

  // Expose a stream for UI updates
  Stream<bool> get onConnectivityChanged => _connectionStreamController.stream;

  // Initial connectivity check
  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    bool isConnected =
        results.any((result) => result != ConnectivityResult.none);
    _isConnected = isConnected;
    _connectionStreamController.add(isConnected);
    print("Initial Connectivity: $results");
  }

  // Manual connectivity check
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  // Synchronous method for UI updates
  bool isConnectedSync() => _isConnected;

  // Dispose to clean up resources
  void dispose() {
    _subscription.cancel();
    _connectionStreamController.close();
  }
}
