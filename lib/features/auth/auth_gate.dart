import 'package:chat_app/features/auth/home_page.dart';
import 'package:chat_app/features/auth/login_page.dart';
import 'package:chat_app/features/chat/chat_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});
  final ChatService chatServices = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
