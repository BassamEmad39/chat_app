import 'package:chat_app/components/buttons/main_button.dart';
import 'package:chat_app/components/dialogs/loading_dialog.dart';
import 'package:chat_app/components/inputs/name_text_form_field.dart';
import 'package:chat_app/core/constants/app_assets.dart';
import 'package:chat_app/core/extensions/navigations.dart';
import 'package:chat_app/core/routers/routers.dart';
import 'package:chat_app/core/utils/text_styles.dart';
import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/features/auth/cubit/auth_cubit.dart';
import 'package:chat_app/features/auth/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? email, password, username;
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => isLoading = true);
        } else if (state is AuthAuthenticated) {
          setState(() => isLoading = false);
          showSuccessDialog(context, 'Registration successful!');
          context.pushWithReplacement(Routes.home);
        } else if (state is AuthError) {
          setState(() => isLoading = false);
          showErrorDialog(context, state.message);
        }
      },
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
                              color: AppColors.blackColor.withValues(alpha: 0.1),
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
                                hintText: 'Username',
                                onChanged: (value) => username = value,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please choose a username';
                                  }
                                  if (value.length < 3) {
                                    return 'Username must be at least 3 characters';
                                  }
                                  return null;
                                },
                              ),
                              const Gap(20),
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
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
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
      context.read<AuthCubit>().registerWithEmailAndPassword(
        email: email!,
        password: password!,
        username: username!,
      );
    }
  }
}