import 'package:flutter_demo/di/injector.dart';
import 'package:flutter_demo/presentation/screens/auth/bloc/login_bloc.dart';
import 'package:flutter_demo/presentation/screens/auth/bloc/login_event.dart';
import 'package:flutter_demo/presentation/screens/auth/bloc/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  // final LoginBloc loginBloc = injector<LoginBloc>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // loginBloc.add(CheckBiometricSupportEvent());
        debugPrint('resume');
        // _checkDeviceSafe();
        break;
      case AppLifecycleState.inactive:
        debugPrint('inactive');
        break;
      case AppLifecycleState.paused:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.detached:
        debugPrint('detached');
        // TODO: Handle this case.
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // loginBloc.add(CheckBiometricSupportEvent());
    });

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

    // _logicListener();
  }

  // void _logicListener([required String state, required String bloc]) {
  //   switch (state) {
  //
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Login Page"),
      ),
    );
  }
}
