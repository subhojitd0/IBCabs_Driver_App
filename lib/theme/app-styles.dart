import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF3F6EDB);
  static const background = Color(0xFFEFEFEF);
  static const textPrimary = Colors.black87;
  static const textSecondary = Colors.grey;
}

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const subHeading = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const buttonText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
  );
}

class AppInputDecoration {
  static InputDecoration input(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }
}
