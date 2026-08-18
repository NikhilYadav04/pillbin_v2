import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pillbin/features/home/data/network/notification_service.dart';
import 'package:pillbin/network/models/api_response.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  static const String _deviceIdKey = 'fcm_device_id';
  static const String _registeredTokenKey = 'fcm_registered_token';
  static const String _lastRegistrationKey = 'fcm_last_registration';
  static const Duration _refreshInterval = Duration(days: 7);

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final NotificationService _notificationService = NotificationService();
  final Logger _logger = Logger();

  Future<void> initialize() async {
    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      autoRegister(force: true);
    });
    await autoRegister();
  }

  Future<String?> _tokenWithRetry() async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) return token;
      } catch (_) {}
      if (attempt < 3) {
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    return null;
  }

  Future<bool> autoRegister({bool force = false}) async {
    try {
      _logger.i('FCM: autoRegister(force: $force) started');

      final token = await _tokenWithRetry();
      if (token == null) {
        _logger.e('FCM: getToken() returned null after 3 attempts');
        return false;
      }
      _logger.i('FCM: token acquired (${token.substring(0, 12)}...)');

      if (!force && !await _shouldRegister(token)) {
        _logger.i('FCM: token unchanged and recently registered, skipping');
        return true;
      }

      final packageInfo = await PackageInfo.fromPlatform();

      final ApiResponse<Map<String, dynamic>> response =
          await _notificationService.registerDeviceToken(
        fcmToken: token,
        deviceId: await getDeviceId(),
        deviceType: Platform.isAndroid
            ? 'android'
            : Platform.isIOS
                ? 'ios'
                : 'web',
        deviceModel: await _deviceModel(),
        appVersion: packageInfo.version,
      );

      if (response.statusCode != 200) {
        _logger.e(
            'FCM: register failed — status ${response.statusCode}, message: ${response.message}');
        return false;
      }
      _logger.i('FCM: token registered with backend');

      await _storage.write(key: _registeredTokenKey, value: token);
      await _storage.write(
          key: _lastRegistrationKey, value: DateTime.now().toIso8601String());
      return true;
    } catch (e) {
      _logger.e('FCM register failed: $e');
      return false;
    }
  }

  Future<bool> _shouldRegister(String token) async {
    final registered = await _storage.read(key: _registeredTokenKey);
    if (registered != token) return true;

    final last = await _storage.read(key: _lastRegistrationKey);
    if (last == null) return true;

    final parsed = DateTime.tryParse(last);
    if (parsed == null) return true;

    return DateTime.now().difference(parsed) >= _refreshInterval;
  }

  Future<String> getDeviceId() async {
    String? id = await _storage.read(key: _deviceIdKey);
    if (id != null && id.isNotEmpty) return id;

    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      id = (await info.androidInfo).id;
    } else if (Platform.isIOS) {
      id = (await info.iosInfo).identifierForVendor;
    }

    if (id == null || id.isEmpty) {
      id = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(99999)}';
    }

    await _storage.write(key: _deviceIdKey, value: id);
    return id;
  }

  Future<String?> _deviceModel() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        return '${android.manufacturer} ${android.model}';
      }
      if (Platform.isIOS) {
        return (await info.iosInfo).utsname.machine;
      }
    } catch (_) {}
    return null;
  }

  Future<void> deactivate() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _notificationService.deactivateDeviceToken(fcmToken: token);
      }
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      _logger.e('FCM deactivate failed: $e');
    }

    await _storage.delete(key: _registeredTokenKey);
    await _storage.delete(key: _lastRegistrationKey);
  }
}
