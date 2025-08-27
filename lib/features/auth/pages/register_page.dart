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

// ignore: must_be_immutable
class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? email, password;

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Gap(50),
                  Center(child: Image.asset(AppAssets.scholar, width: 100)),
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
                    isPassword: true,
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Gap(20),
                  Gap(20),
                  MainButton(
                    text: 'Register',
                    onPressed: () async {
                      try {
                        isLoading = true;
                        setState(() {});
                        await registerUser(context);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          showErrorDialog(
                            context,
                            'The password provided is too weak.',
                          );
                        } else if (e.code == 'invalid-email') {
                          showErrorDialog(
                            context,
                            'The email address is not valid.',
                          );
                        } else if (e.code == 'email-already-in-use') {
                          showErrorDialog(
                            context,
                            'The account already exists for that email.',
                          );
                        } else {
                          showErrorDialog(context, e.toString());
                        }
                      }
                      isLoading = false;
                      setState(() {});
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
        ),
      ),
    );
  }

  Future<void> registerUser(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      var auth = FirebaseAuth.instance;
      // ignore: unused_local_variable
      UserCredential user = await auth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      showSuccessDialog(context, 'Registration successful!');
    }
  }
}
