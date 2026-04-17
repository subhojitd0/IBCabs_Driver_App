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

    // ✅ Validation
    if (id.isEmpty || password.isEmpty) {
      SnackbarHelper.showError(context, "User ID and Password cannot be empty");
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.login(id, password, token);

    setState(() => isLoading = false);

    if (result["success"]) {
      final username = result["data"]["username"] ?? "User";
      final drivername = result["data"]["drivername"] ?? "User";

      await AuthService.saveLogin(username, drivername);

      SnackbarHelper.showSuccess(context, 'Login Successful for $drivername');

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
      backgroundColor: AppColors.primary(context),

      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.primary(context),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 35,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text("Welcome Back", style: AppTextStyles.heading(context)),

                  const SizedBox(height: 5),

                  Text(
                    "Login to continue",
                    style: AppTextStyles.subHeading(context),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: idController,
                    decoration: AppInputDecoration.input(context, "User ID"),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: AppInputDecoration.input(context, "Password"),
                  ),

                  const SizedBox(height: 30),

                  isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary(context),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: AppTextStyles.buttonText(context),
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),

                  Text(
                    "Forgot Password?",
                    style: TextStyle(color: AppColors.textSecondary(context)),
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
