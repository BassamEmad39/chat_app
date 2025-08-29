import 'package:chat_app/core/constants/app_fonts.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/core/utils/text_styles.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.blue,
    fontFamily: AppFonts.poppins,
    colorScheme: ColorScheme.light(
      primary: Colors.grey.shade500,
      secondary: Colors.grey.shade200,
      tertiary: AppColors.whiteColor,
      inversePrimary: Colors.grey.shade900,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.whiteColor,
      filled: true,
      hintStyle: TextStyles.getSmall(),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.darkColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.darkColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
    ),
  );
}
