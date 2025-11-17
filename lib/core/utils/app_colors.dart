import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF00BCD4);
  static const Color secondaryColor = Color(0xFF8E2DE2);

  static const Color blackColor = Color(0xFF1C1C1E);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color greyColor = Color(0xFF9E9E9E);
  static const Color borderColor = Color(0xFFE0E0E0);

  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);

  static const LinearGradient mainGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
