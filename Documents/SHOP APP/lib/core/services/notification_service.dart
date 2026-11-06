import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'supabase_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background FCM message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFirebaseReady = false;
  bool get isFirebaseReady => _isFirebaseReady;
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  final StreamController<String> _onOrderNotificationTapped = StreamController<String>.broadcast();
  Stream<String> get onOrderNotificationTapped => _onOrderNotificationTapped.stream;

  Future<void> initialize() async {
    // 1. Initialize Local Notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          _onOrderNotificationTapped.add(response.payload!);
        }
      },
    );

    // Create high-importance Android Notification Channel
    const androidChannel = AndroidNotificationChannel(
      'admin_orders_channel',
      'Admin Orders Alerts',
      description: 'Instant notification whenever a new order is placed or cancelled',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(androidChannel);
    await androidPlugin?.requestNotificationsPermission();

    // 2. Try initializing Firebase safely (if google-services.json is configured)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _isFirebaseReady = true;

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _fcmToken = await messaging.getToken();
        debugPrint('📲 FCM Token obtained: $_fcmToken');

        // Sync FCM token to Supabase if logged in
        final user = SupabaseService().currentUser;
        if (user != null && _fcmToken != null) {
          await SupabaseService().updateProfile(userId: user.id, fcmToken: _fcmToken);
        }

        // Listen for foreground FCM messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Foreground FCM message received: ${message.notification?.title}');
          showNotification(
            title: message.notification?.title ?? 'Order Alert',
            body: message.notification?.body ?? '',
            payload: message.data['order_id'] ?? '',
          );
        });

        // Listen for notification tap opening the app
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          final orderId = message.data['order_id'];
          if (orderId != null) {
            _onOrderNotificationTapped.add(orderId);
          }
        });
      }
    } catch (e) {
      debugPrint('ℹ️ Firebase not initialized yet (Google services json pending): $e');
    }
  }

  /// Show a high-priority local notification with sound & vibration
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'admin_orders_channel',
      'Admin Orders Alerts',
      channelDescription: 'Instant notification whenever a new order is placed or cancelled',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  /// Trigger a rich heads-up alert for an incoming customer order
  Future<void> showNewOrderAlert({
    required String orderNumber,
    required String customerName,
    required double totalAmount,
    required String paymentMethod,
    String? orderId,
  }) async {
    await showNotification(
      title: '🛍️ New Order Placed: #$orderNumber',
      body: '$customerName just ordered ₹${totalAmount.toStringAsFixed(0)} ($paymentMethod). Tap to view and confirm!',
      payload: orderId,
    );
  }

  /// Send a quick test notification to verify audio, vibration, and system tray banner
  Future<void> sendTestAdminNotification() async {
    await showNotification(
      title: '🔔 Admin Alert Test',
      body: 'Notifications are active! You will be alerted instantly whenever a customer places an order.',
    );
  }

  void dispose() {
    _onOrderNotificationTapped.close();
  }
}
