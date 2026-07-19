import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/api_client.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();

  factory NotificationManager() {
    return _instance;
  }

  NotificationManager._internal();

  static Future<void> initialize() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('Firebase Messaging Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Received a foreground message: ${message.notification?.title}');

      const channel = MethodChannel("com.testapk.app/app_launcher");
      await channel.invokeMethod("showNotification", {
        "title": message.notification?.title ?? "",
        "body": message.notification?.body ?? "",
      });
    });

    // Handle when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('User opened the app from a notification: ${message.notification?.title}');
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> sendTokenToServer() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        debugPrint('Sending FCM Token to server: $token');
        final response = await ApiClient.instance.post('/users/fcm-token', {'token': token});
        if (response.statusCode == 200) {
          debugPrint('FCM Token successfully registered on server');
        } else {
          debugPrint('Failed to register FCM Token on server: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.notification!.title}');
}