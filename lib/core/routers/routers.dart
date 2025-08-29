
import 'package:chat_app/features/auth/auth_gate.dart';
import 'package:chat_app/features/auth/home_page.dart';
import 'package:chat_app/features/auth/login_page.dart';
import 'package:chat_app/features/auth/register_page.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';

  static final routers = GoRouter(
    routes: [
      GoRoute(path: splash, builder: (context, state) => AuthGate()),
      GoRoute(path: login, builder: (context, state) => LoginPage()),
      GoRoute(path: register, builder: (context, state) => RegisterPage()),
      GoRoute(path: home, builder: (context, state) => HomePage()),
    ],
  );
}

    
