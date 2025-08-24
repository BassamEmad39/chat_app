import 'package:chat_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class TextStyles {
  static TextStyle getHeadLine1({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      color: color ?? AppColors.darkColor,
      fontSize: fontSize ?? 30,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  static TextStyle getHeadLine2({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      color: color ?? AppColors.darkColor,
      fontSize: fontSize ?? 24,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  static TextStyle getTitle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      color: color ?? AppColors.darkColor,
      fontSize: fontSize ?? 18,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  static TextStyle getBody({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      color: color ?? AppColors.darkColor,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  static TextStyle getSmall({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      color: color ?? AppColors.greyColor,
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }
}
