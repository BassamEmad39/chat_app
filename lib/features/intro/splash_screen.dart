import 'package:chat_app/core/constants/app_assets.dart';
import 'package:chat_app/core/extensions/navigations.dart';
import 'package:chat_app/core/routers/routers.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/core/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      context.pushWithReplacement(Routes.login);
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.scholar, width: 100),
            Gap(30),
            Text(
              'Chat with your friends!',
              style: TextStyles.getHeadLine2(
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
