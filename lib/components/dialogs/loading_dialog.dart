import 'package:chat_app/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => Lottie.asset(AppAssets.loadingLottie),
  );
}

showErrorDialog(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
}

showSuccessDialog(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.green,
    ),
  );
}
