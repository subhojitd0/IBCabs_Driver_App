import 'package:flutter/material.dart';

class AppColors {
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

  static Color border(BuildContext context) => Theme.of(context).dividerColor;

  static Color inputFill(BuildContext context) => Theme.of(context).cardColor;
}

class AppTextStyles {
  static TextStyle heading(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary(context),
  );

  static TextStyle subHeading(BuildContext context) =>
      TextStyle(fontSize: 12, color: AppColors.textSecondary(context));

  static TextStyle buttonText(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onPrimary,
    fontWeight: FontWeight.w500,
  );
}

class AppInputDecoration {
  static InputDecoration input(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary(context).withOpacity(0.7),
      ),
      filled: true,
      fillColor: AppColors.inputFill(context),

      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.border(context)),
      ),

      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary(context), width: 2),
      ),
    );
  }
}
