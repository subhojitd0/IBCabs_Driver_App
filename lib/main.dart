import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // 👈 REQUIRED
  await NotificationService.initialize(); // 👈 THIS FIXES UNUSED IMPORT

  runApp(const IBCabsApp());
}

class IBCabsApp extends StatelessWidget {
  const IBCabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashDecider(),
    );
  }
}

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  bool? isLoggedIn;
  String? username;
  String? drivername;

  @override
  void initState() {
    super.initState();

    setupFCM(); // 👈 ADD THIS
    checkLogin();
  }

  void checkLogin() async {
    final loggedIn = await AuthService.isLoggedIn();
    final user = await AuthService.getUserDetails();

    setState(() {
      isLoggedIn = loggedIn;
      username = user["username"];
      drivername = user["drivername"];
    });
  }

  void setupFCM() async {
    // 🔔 App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      final user = await AuthService.getUserDetails();

      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            username: user["username"] ?? "User",
            drivername: user["drivername"] ?? "Driver",
          ),
        ),
      );
    });

    // 🔔 App opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        final user = await AuthService.getUserDetails();

        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              username: user["username"] ?? "User",
              drivername: user["drivername"] ?? "Driver",
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isLoggedIn!) {
      return DashboardScreen(
        username: username ?? "User",
        drivername: drivername ?? "Driver",
      );
    } else {
      return const LoginScreen();
    }
  }
}
