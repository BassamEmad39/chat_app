import 'package:chat_app/components/buttons/main_button.dart';
import 'package:chat_app/components/inputs/name_text_field.dart';
import 'package:chat_app/core/constants/app_assets.dart';
import 'package:chat_app/core/extensions/navigations.dart';
import 'package:chat_app/core/routers/routers.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/core/utils/text_styles.dart';
import 'package:chat_app/features/auth/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void login() async {
    final authService = AuthServices();
    try {
      await authService.signInWithEmail(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      print('Error logging in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Image.asset(AppAssets.scholar, width: 150)),
                Gap(50),
                Text(
                  'Login here',
                  style: TextStyles.getHeadLine1(
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                ),
                Gap(10),
                Text(
                  'Welcome back! you\'ve been missed.',
                  style: TextStyles.getHeadLine2(color: AppColors.whiteColor),
                ),
                Gap(50),
                NameTextField(hintText: 'Email', controller: emailController),
                Gap(20),
                NameTextField(
                  hintText: 'Password',
                  isPassword: true,
                  controller: passwordController,
                ),
                Gap(30),
                MainButton(
                  text: 'Login',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      login();
                    }
                  },
                ),
                Gap(20),
                Row(
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: TextStyles.getBody(color: AppColors.whiteColor),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pushWithReplacement(Routes.register);
                      },
                      child: Text(
                        'Register now!',
                        style: TextStyles.getBody(
                          color: AppColors.cyanColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
