import 'package:chat_app/features/auth/pages/login_page.dart';
import 'package:chat_app/features/auth/pages/register_page.dart';
import 'package:chat_app/features/intro/splash_screen.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  static final routers = GoRouter(
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: login, builder: (context, state) => LoginPage()),
      GoRoute(path: register, builder: (context, state) => RegisterPage()),
    ],
  );
}

    
