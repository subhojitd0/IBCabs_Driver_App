import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ NEW
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'utils/theme_helper.dart'; // ✅ NEW
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await NotificationService.initialize();

  final themeService = ThemeService();
  await themeService.loadTheme(); // 🔥 LOAD SAVED THEME

  // ✅ STEP 2: WRAP APP WITH PROVIDER
  runApp(
    ChangeNotifierProvider.value(
      // ✅ USE .value
      value: themeService,
      child: const IBCabsApp(),
    ),
  );
}

class IBCabsApp extends StatelessWidget {
  const IBCabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ STEP 2: LISTEN TO THEME SERVICE
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,

          // 🌞 Light Theme
          theme: ThemeData.light(),

          // 🌙 Dark Theme
          darkTheme: ThemeData.dark(),

          // 🔥 DYNAMIC SWITCH
          themeMode: themeService.isDark ? ThemeMode.dark : ThemeMode.light,

          home: const SplashDecider(),
        );
      },
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

    setupFCM();
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

    // 🔔 App opened from terminated
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
