import 'package:chat_app/core/constants/app_fonts.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/core/utils/text_styles.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.blue,
    fontFamily: AppFonts.poppins,
    colorScheme: ColorScheme.light(
      primary: AppColors.greyColor,
      secondary: AppColors.greyColor.withValues(alpha: 0.2),
      tertiary: AppColors.whiteColor,
      inversePrimary: AppColors.blackColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.whiteColor,
      filled: true,
      hintStyle: TextStyles.getSmall(),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.blackColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.blackColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.errorColor, width: 1.5),
      ),
    ),
  );
}
