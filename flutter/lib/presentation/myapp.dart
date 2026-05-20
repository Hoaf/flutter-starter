import 'package:flutter_demo/presentation/config/app_theme.dart';
import 'package:flutter_demo/presentation/helper/loading_helper.dart';
import 'package:flutter_demo/presentation/routes/routers.dart';
import 'package:flutter/material.dart';
import 'package:lifecycle/lifecycle.dart';

import 'screens/widgets/app_protector/application_protector.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('resumed');
        break;
      case AppLifecycleState.inactive:
        debugPrint('inactive');
        break;
      case AppLifecycleState.paused:
        debugPrint('paused');
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      builder: LoadingHelper.initLoading(
        builder: (context, child) =>
            ApplicationProtectorWidget(child: child),
      ),
      navigatorObservers: [
        defaultLifecycleObserver,
        AppRouter.routeObserver,
      ],
      theme: AppTheme.light,
      routes: AppRouter.routes,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
