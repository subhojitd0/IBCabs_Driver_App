import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else {
        print('User denied notification permission');
      }
      print("Notification permission: ${settings.authorizationStatus}");

      try {
        String? token = await _messaging.getToken();
        print("FCM Token: $token");
      } catch (e) {
        print("FCM token error: $e");
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final context = navigatorKey.currentContext;

        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message.notification?.title ?? "New Notification"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } catch (e) {
      print("Notification service init error: $e");
    }
  }
}
