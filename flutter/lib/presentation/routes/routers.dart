import 'package:flutter_demo/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_demo/presentation/screens/home/home_page.dart';
import 'package:flutter/material.dart';

abstract class AppRouter {
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String plashRoute = '/plash';
  static const String dashboardRoute = '/dashboard';
  static const String testRoute = '/test';
  static const String homeRoute = '/home';

  static final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Map<String, Widget Function(BuildContext)> routes = {
    initialRoute: (context) => const LoginPage(),
    '/home': (context) => const HomePage(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.loginRoute:
        var arg = settings.arguments;

        return MaterialPageRoute<dynamic>(
          settings: RouteSettings(
            name: AppRouter.loginRoute,
            arguments: arg,
          ),
          builder: (context) {
            return LoginPage();
          },
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
