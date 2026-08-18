import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pillbin/config/notifications/notification_model.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationConfig {
  //* Singleton pattern — ensures only one instance exists throughout app

  static final NotificationConfig _instance = NotificationConfig._internal();
  factory NotificationConfig() => _instance;
  NotificationConfig._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String urgentChannel = 'action_required_channel';
  static const String urgentSilentChannel = 'action_required_silent_channel';
  static const String infoChannel = 'informational_channel';
  static const String infoSilentChannel = 'informational_silent_channel';

  static const Set<String> _urgentTypes = {
    'medicine_expired',
    'donation_approved',
    'donation_rejected',
    'center_verified',
    'center_verification_rejected',
  };

  static const Map<String, String> _routeForType = {
    'medicine_expiring_soon': '/inventory-screen',
    'medicine_expired': '/inventory-screen',
    'donation_submitted': '/vendor-requests-screen',
    'donation_cancelled': '/vendor-requests-screen',
    'donation_approved': '/my-donations-screen',
    'donation_rejected': '/my-donations-screen',
    'donation_completed': '/my-donations-screen',
    'center_verified': '/vendor-dashboard-screen',
    'center_verification_rejected': '/vendor-dashboard-screen',
  };

  GlobalKey<NavigatorState>? _navigatorKey;
  VoidCallback? onMessageReceived;
  bool _initialized = false;

  //* Initialize notification settings
  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    if (_initialized) return;
    _navigatorKey = navigatorKey;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null) return;
        try {
          _route(jsonDecode(response.payload!) as Map<String, dynamic>);
        } catch (_) {}
      },
    );

    if (Platform.isAndroid) await _createChannels();

    await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    if (Platform.isAndroid) await Permission.notification.request();

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _route(m.data));
    FirebaseMessaging.instance.getInitialMessage().then((m) {
      if (m != null) _route(m.data);
    });

    _initialized = true;
  }

  Future<void> _createChannels() async {
    final plugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    const channels = [
      AndroidNotificationChannel(
        urgentChannel,
        'Action Required',
        description: 'Expiry alerts and donation updates',
        importance: Importance.high,
        playSound: true,
      ),
      AndroidNotificationChannel(
        urgentSilentChannel,
        'Action Required (Silent)',
        description: 'Expiry alerts and donation updates, muted',
        importance: Importance.high,
        playSound: false,
      ),
      AndroidNotificationChannel(
        infoChannel,
        'Updates',
        description: 'General PillBin updates',
        importance: Importance.defaultImportance,
        playSound: true,
      ),
      AndroidNotificationChannel(
        infoSilentChannel,
        'Updates (Silent)',
        description: 'General PillBin updates, muted',
        importance: Importance.defaultImportance,
        playSound: false,
      ),
    ];

    for (final channel in channels) {
      await plugin?.createNotificationChannel(channel);
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    try {
      onMessageReceived?.call();
    } catch (_) {}

    final notification = message.notification;
    if (notification == null) return;

    final type = message.data['type']?.toString() ?? '';

    await _show(
      title: notification.title ?? 'PillBin',
      body: notification.body ?? '',
      urgent: _urgentTypes.contains(type),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _show({
    required String title,
    required String body,
    required bool urgent,
    String? payload,
  }) async {
    final channelId = urgent ? urgentChannel : infoChannel;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        urgent ? 'Action Required' : 'Updates',
        importance: urgent ? Importance.high : Importance.defaultImportance,
        priority: urgent ? Priority.high : Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          htmlFormatContent: true,
          htmlFormatTitle: true,
        ),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _route(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final route = _routeForType[type] ?? '/notification-screen';

    Future.delayed(const Duration(milliseconds: 500), () {
      _navigatorKey?.currentState?.pushNamed(route);
    });
  }

  //* Show an instant notification
  Future<void> showInstantNotification(
      {required PushNotificationModel notify}) async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
          'instant_notification_channel_id', 'Instant Notifications',
          channelDescription: 'Instant notification channel',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            notify.body,
            contentTitle: notify.title,
            htmlFormatContent: true,
            htmlFormatTitle: true,
          )),
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
        int.parse(notify.id), notify.title, notify.body, notificationDetails);
  }
}
