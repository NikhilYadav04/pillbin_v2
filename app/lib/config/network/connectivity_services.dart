import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  final _statusController = StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  ConnectivityStatus _lastStatus = ConnectivityStatus.online;
  StreamSubscription? _connectivitySubscription;

  ConnectivityService._internal() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_handleUpdate);
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final results = await _connectivity.checkConnectivity();
    _handleUpdate(results);
  }

  void _handleUpdate(List<ConnectivityResult> results) {
    final status = results.any((result) => result != ConnectivityResult.none)
        ? ConnectivityStatus.online
        : ConnectivityStatus.offline;

    if (status != _lastStatus) {
      _lastStatus = status;
      _statusController.add(status);

      // Trigger tactile feedback
      if (status == ConnectivityStatus.offline) {
        HapticFeedback.heavyImpact(); // Strong warning for total loss
      } else {
        HapticFeedback.lightImpact(); // Subtle confirmation of restore
      }
    }
  }

  bool get isOnline => _lastStatus == ConnectivityStatus.online;
  ConnectivityStatus get currentStatus => _lastStatus;

  void dispose() {
    _statusController.close();
  }
}
