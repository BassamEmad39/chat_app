import 'package:chat_app/components/buttons/main_button.dart';
import 'package:chat_app/components/dialogs/loading_dialog.dart';
import 'package:chat_app/components/inputs/name_text_form_field.dart';
import 'package:chat_app/core/constants/app_assets.dart';
import 'package:chat_app/core/extensions/navigations.dart';
import 'package:chat_app/core/routers/routers.dart';
import 'package:chat_app/core/utils/text_styles.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? email, password;
  final formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.mainGradient),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Image.asset(AppAssets.logo, width: 80),
                      ),
                      const Gap(30),
                      Text(
                        'Create Account',
                        style: TextStyles.getHeadLine1(
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Please fill in the details to get started',
                        style: TextStyles.getHeadLine2(
                          color: AppColors.whiteColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const Gap(40),
                      Card(
                        color: AppColors.whiteColor,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              NameTextFormField(
                                hintText: 'Email',
                                onChanged: (value) => email = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                              ),
                              const Gap(20),
                              NameTextFormField(
                                hintText: 'Password',
                                isPassword: true,
                                onChanged: (value) => password = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const Gap(30),
                              MainButton(
                                text: 'Register',
                                textColor: AppColors.whiteColor,
                                onPressed: _handleRegister,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyles.getBody(
                              color: AppColors.whiteColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.pushWithReplacement(Routes.login);
                            },
                            child: Text(
                              'Login now!',
                              style: TextStyles.getBody(
                                color: Colors.yellowAccent,
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
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email!, password: password!);

        _firestore.collection('Users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
        });

        showSuccessDialog(context, 'Registration successful!');
        context.pushWithReplacement(Routes.home);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          showErrorDialog(context, 'The password provided is too weak.');
        } else if (e.code == 'invalid-email') {
          showErrorDialog(context, 'The email address is not valid.');
        } else if (e.code == 'email-already-in-use') {
          showErrorDialog(context, 'An account already exists for that email.');
        } else {
          showErrorDialog(context, e.message ?? 'Something went wrong');
        }
      }
      setState(() => isLoading = false);
    }
  }
}
