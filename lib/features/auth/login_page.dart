import 'package:chat_app/components/buttons/main_button.dart';
import 'package:chat_app/components/dialogs/loading_dialog.dart';
import 'package:chat_app/components/inputs/name_text_form_field.dart';
import 'package:chat_app/core/constants/app_assets.dart';
import 'package:chat_app/core/extensions/navigations.dart';
import 'package:chat_app/core/routers/routers.dart';
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF6A11CB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
                          color: Colors.white,
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
                        'Welcome Back',
                        style: TextStyles.getHeadLine1(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Login to continue chatting',
                        style: TextStyles.getHeadLine2(color: Colors.white70),
                      ),
                      const Gap(40),

                      Card(
                        color: Colors.white,
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
                                text: 'Login',
                                onPressed: _handleLogin,
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
                            'Don\'t have an account?',
                            style: TextStyles.getBody(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              context.pushWithReplacement(Routes.register);
                            },
                            child: Text(
                              'Register now!',
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

  Future<void> _handleLogin() async {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email!,
          password: password!,
        );
        showSuccessDialog(context, 'Login successful!');
        context.pushWithReplacement(Routes.home);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showErrorDialog(context, 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          showErrorDialog(context, 'Wrong password provided.');
        } else {
          showErrorDialog(context, e.message ?? 'Something went wrong.');
        }
      }
      setState(() => isLoading = false);
    }
  }
}
