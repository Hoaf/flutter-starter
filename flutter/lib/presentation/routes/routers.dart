import 'package:flutter_demo/presentation/screens/auth/login_page.dart';
import 'package:flutter_demo/presentation/screens/test/test_page.dart';
import 'package:flutter/material.dart';

abstract class AppRouter {
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String plashRoute = '/plash';
  static const String dashboardRoute = '/dashboard';
  static const String testRoute = '/test';

  static final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Map<String, Widget Function(BuildContext)> routes = {
    initialRoute: (context) => const TestPage(),
    testRoute: (context) => const TestPage(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.loginRoute:
        // var arg = settings.arguments as NotificationArguments?;
        return MaterialPageRoute<dynamic>(
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
