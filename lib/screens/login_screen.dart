import 'package:flutter/material.dart';
import '../theme/app-styles.dart';
import '../services/login_service.dart';
import 'dashboard_screen.dart';
import '../services/auth_service.dart';
import '../utils/snackbar_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final idController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;

  void handleLogin() async {
    String id = idController.text.trim();
    String password = passController.text.trim();
    String? token = await FirebaseMessaging.instance.getToken();

    // ✅ Validation check
    if (id.isEmpty || password.isEmpty) {
      SnackbarHelper.showError(context, "User ID and Password cannot be empty");
      return; // ⛔ STOP execution
    }

    setState(() => isLoading = true);

    final result = await ApiService.login(
      idController.text,
      passController.text,
      token,
    );

    if (result["success"]) {
      final username = result["data"]["username"] ?? "User";
      final drivername = result["data"]["drivername"] ?? "User";

      // ✅ Save session
      await AuthService.saveLogin(username, drivername);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DashboardScreen(username: username, drivername: drivername),
        ),
      );
    }

    setState(() => isLoading = false);

    if (result["success"]) {
      final username = result["data"]["username"] ?? "User";
      final drivername = result["data"]["drivername"] ?? "User";
      SnackbarHelper.showSuccess(context, 'Login Succesful for $drivername');
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DashboardScreen(username: username, drivername: drivername),
        ),
      );
    } else {
      SnackbarHelper.showError(context, result["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Bottom white container (card style)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 35),
                  ),
                  const SizedBox(height: 20),

                  const Text("Welcome Back", style: AppTextStyles.heading),
                  const SizedBox(height: 5),
                  const Text(
                    "Login to continue",
                    style: AppTextStyles.subHeading,
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: idController,
                    decoration: AppInputDecoration.input("User ID"),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: AppInputDecoration.input("Password"),
                  ),

                  const SizedBox(height: 30),

                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              "Login",
                              style: AppTextStyles.buttonText,
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),

                  const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
