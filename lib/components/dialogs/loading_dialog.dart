import 'package:chat_app/core/constants/app_assets.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.blackColor.withValues(alpha: 0.5),
    builder: (context) => Lottie.asset(AppAssets.loadingLottie),
  );
}

showErrorDialog(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.redColor,
      duration: Duration(seconds: 3),
    ),
  );
}

showSuccessDialog(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      backgroundColor: AppColors.greenColor,
    ),
  );
}
