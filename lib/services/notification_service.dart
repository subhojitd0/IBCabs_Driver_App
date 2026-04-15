import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else {
      print('User denied notification permission');
    }

    // Get FCM Token
    String? token = await _messaging.getToken();
    print("FCM Token: $token");

    // Foreground notifications
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

    // When notification clicked
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked!");
    });
  }
}
