import 'package:flutter_demo/di/injector.dart';
import 'package:flutter_demo/domain/usecases/auth_usecase.dart';
import 'package:flutter_demo/presentation/localization/localization.dart';
import 'package:flutter_demo/presentation/routes/routers.dart';
import 'package:flutter_demo/presentation/screens/auth/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:lifecycle/lifecycle.dart';

import 'config/app_colors.dart';
import 'helper/loading_helper.dart';
import 'screens/widgets/app_protector/application_protector.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final IAuthUseCase _authUseCase = GetIt.I<IAuthUseCase>();

  @override
  void initState() {
    debugPrint("initState in BASE state");
    //make sure you are observing your app lifecycle
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
    debugPrint("didChangeAppLifecycleState in BASE state");
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('resume: setLastTimeInteract');
        // _authUseCase.setLastTimeInteract(DateTime.now().millisecondsSinceEpoch);
        break;
      case AppLifecycleState.inactive:
        debugPrint('inactive');
        break;
      case AppLifecycleState.paused:
        debugPrint("paused: setLastTimeInteract");
        break;
      case AppLifecycleState.detached:
      // TODO: Handle this case.
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
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
      theme: ThemeData(
          appBarTheme: Theme.of(context)
              .appBarTheme
              .copyWith(systemOverlayStyle: SystemUiOverlayStyle.dark),
          // primaryColor: AppColors.primary,
          // colorSchemeSeed: Colors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.blue,
            // // brightness: Brightness.light,
            // primary: AppColors.blue,
            // onPrimary: AppColors.white,
              // primaryContainer: AppColors.white,
              // onPrimaryContainer: AppColors.white,
              // primaryFixed: AppColors.white,
              // primaryFixedDim: AppColors.white,
              // onPrimaryFixed: AppColors.white,
              // onPrimaryFixedVariant: AppColors.white,
              // secondary: AppColors.white,
              // onSecondary: AppColors.white,
              // secondaryContainer: AppColors.white,
              // onSecondaryContainer: AppColors.white,
              // secondaryFixed: AppColors.white,
              // secondaryFixedDim: AppColors.white,
              // onSecondaryFixed: AppColors.white,
              // onSecondaryFixedVariant: AppColors.white,
              // tertiary: AppColors.white,
              // onTertiary: AppColors.white,
              // tertiaryContainer: AppColors.white,
              // onTertiaryContainer: AppColors.white,
              // tertiaryFixed: AppColors.white,
              // tertiaryFixedDim: AppColors.white,
              // onTertiaryFixed: AppColors.white,
              // onTertiaryFixedVariant: AppColors.white,
              // error: AppColors.white,
              // onError: AppColors.white,
              // errorContainer: AppColors.white,
              // onErrorContainer: AppColors.white,
              // outline: AppColors.white,
              // outlineVariant: AppColors.white,
              surface: const Color.fromRGBO(250, 250, 250, 1),
              // onSurface: AppColors.red,
              // surfaceDim: AppColors.transparent,
              // surfaceBright: AppColors.transparent,
              // surfaceContainerLowest: AppColors.white,
              // surfaceContainerLow: AppColors.white,
              // surfaceContainer: AppColors.white,
              // surfaceContainerHigh: AppColors.white,
              // surfaceContainerHighest: AppColors.white,
              // onSurfaceVariant: AppColors.white,
              // inverseSurface: AppColors.white,
              // onInverseSurface: AppColors.white,
              // inversePrimary: AppColors.white,
              // shadow: AppColors.white,
              // scrim: AppColors.white,
              // surfaceTint: AppColors.white,
              // background: AppColors.white,
              // onBackground: AppColors.white,
              // surfaceVariant: AppColors.white
          ),
          fontFamily: 'Ubuntu',
          textTheme: Theme.of(context)
              .textTheme
              .apply(fontFamily: 'Ubuntu'),
          fontFamilyFallback: const ['Ubuntu']
      ),
      routes: AppRouter.routes,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
      // localizationsDelegates: const [
      //   // Localization.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: Localization.supportedLocales,
    );
  }
}
