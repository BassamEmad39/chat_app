import 'package:chat_app/core/routers/routers.dart';
import 'package:chat_app/core/utils/themes.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppThemes.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: Routes.routers,
    );
  }
}
