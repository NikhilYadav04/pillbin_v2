import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _showConnectedBanner = false;
  Timer? _dismissTimer;
  bool _wasConnected = true;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _onConnectionEstablished() {
    if (!mounted) return;
    setState(() => _showConnectedBanner = true);

    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showConnectedBanner = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService();

    return StreamBuilder<ConnectivityStatus>(
      stream: connectivityService.statusStream,
      initialData: connectivityService.currentStatus,
      builder: (context, snapshot) {
        final isOnline = snapshot.data == ConnectivityStatus.online;

        if (!isOnline) {
          // Went offline
          if (_wasConnected) {
            _wasConnected = false;
          }
          _showConnectedBanner = false;
          _dismissTimer?.cancel();

          return _buildBanner(
            context,
            'No Internet Connection',
            Icons.wifi_off,
            Theme.of(context).colorScheme.error,
            Theme.of(context).colorScheme.onError,
          );
        }

        // Came back online
        if (!_wasConnected) {
          _wasConnected = true;
          Future.microtask(_onConnectionEstablished);
        }

        // Show green "Connected" banner briefly
        if (_showConnectedBanner) {
          return _buildBanner(
            context,
            'Connected',
            Icons.check_circle,
            Colors.green.shade600,
            Colors.white,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBanner(
    BuildContext context,
    String message,
    IconData icon,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 12),
            Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
