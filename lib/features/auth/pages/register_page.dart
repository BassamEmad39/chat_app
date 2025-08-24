import 'package:chat_app/components/buttons/main_button.dart';
import 'package:chat_app/components/dialogs/loading_dialog.dart';
import 'package:chat_app/components/inputs/name_text_field.dart';
import 'package:chat_app/core/constants/app_assets.dart';
import 'package:chat_app/core/extensions/navigations.dart';
import 'package:chat_app/core/routers/routers.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/core/utils/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  String? email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Image.asset(AppAssets.scholar, width: 150)),
              Gap(50),
              Text(
                'Register here',
                style: TextStyles.getHeadLine1(
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor,
                ),
              ),
              Gap(10),
              Text(
                'Welcome! Please fill in the details to create an account.',
                style: TextStyles.getHeadLine2(color: AppColors.whiteColor),
              ),
              Gap(50),
              NameTextField(
                hintText: 'Email',
                onChanged: (value) {
                  email = value;
                },
              ),
              Gap(20),
              NameTextField(
                hintText: 'Password',
                isPassword: true,
                onChanged: (value) {
                  password = value;
                },
              ),
              Gap(20),
              Gap(20),
              MainButton(
                text: 'Register',
                onPressed: () async {
                  showLoadingDialog(context);
                  try {
                    await registerUser(context);
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'weak-password') {
                      context.pop();
                      showErrorDialog(
                        context,
                        'The password provided is too weak.',
                      );
                    } else if (e.code == 'invalid-email') {
                      context.pop();
                      showErrorDialog(
                        context,
                        'The email address is not valid.',
                      );
                    } else if (e.code == 'email-already-in-use') {
                      context.pop();
                      showErrorDialog(
                        context,
                        'The account already exists for that email.',
                      );
                    } else {
                      context.pop();
                      showErrorDialog(context, e.toString());
                    }
                  }
                },
              ),
              Gap(20),
              Row(
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyles.getBody(color: AppColors.whiteColor),
                  ),
                  TextButton(
                    onPressed: () {
                      context.pushWithReplacement(Routes.login);
                    },
                    child: Text(
                      'Login now!',
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
    );
  }

  Future<void> registerUser(BuildContext context) async {
    var auth = FirebaseAuth.instance;
    // ignore: unused_local_variable
    UserCredential user = await auth.createUserWithEmailAndPassword(
      email: email!,
      password: password!,
    );
    context.pop();
    showSuccessDialog(context, 'Registration successful!');
  }
}
