// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:chat_app/components/buttons/main_button.dart';
import 'package:chat_app/components/dialogs/loading_dialog.dart';
import 'package:chat_app/components/inputs/name_text_form_field.dart';
import 'package:chat_app/core/constants/app_assets.dart';
import 'package:chat_app/core/extensions/navigations.dart';
import 'package:chat_app/core/routers/routers.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/core/utils/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email, password;

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Gap(50),
                  Center(child: Image.asset(AppAssets.scholar, width: 100)),
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
                  NameTextFormField(
                    hintText: 'Email',
                    onChanged: (value) {
                      email = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  Gap(20),
                  NameTextFormField(
                    hintText: 'Password',
                    onChanged: (value) {
                      password = value;
                    },
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Gap(30),
                  MainButton(
                    text: 'Login',
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        isLoading = true;
                        setState(() {});
                        try {
                          await login();
                          showSuccessDialog(context, 'Login successful!');
                          context.pushWithReplacement(Routes.chat);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            showErrorDialog(
                              context,
                              'No user found for that email.',
                            );
                          } else if (e.code == 'wrong-password') {
                            showErrorDialog(
                              context,
                              'Wrong password provided for that user.',
                            );
                          }
                        } catch (e) {
                          log(e.toString());
                          showErrorDialog(context, 'There was an error');
                        }
                        isLoading = false;
                        setState(() {});
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
      ),
    );
  }

  Future<void> login() async {
    // ignore: unused_local_variable
    UserCredential user = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email!, password: password!);
  }
}
