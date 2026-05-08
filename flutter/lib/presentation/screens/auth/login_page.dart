import 'package:flutter/services.dart';
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

  void _updateStatusBar(int index) {
    if (index == 0) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Android
          statusBarBrightness: Brightness.light,     // iOS
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, // Android
          statusBarBrightness: Brightness.dark,      // iOS
        ),
      );
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
    final inset = MediaQuery
        .of(context)
        .padding;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top: inset.top + 10),
            // margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Icon
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.teal.withOpacity(0.2),
                  child: const Icon(Icons.shopping_bag, color: Colors.teal),
                ),
        
                const SizedBox(height: 20),
        
                /// Title
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        
                const SizedBox(height: 8),
        
                const Text(
                  "Please enter your details",
                  style: TextStyle(color: Colors.grey),
                ),
        
                const SizedBox(height: 20),
        
                /// Tab Login / Signup
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _tabItem("Login", true),
                      _tabItem("Sign Up", false),
                    ],
                  ),
                ),
        
                const SizedBox(height: 20),
        
                /// Username
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Username"),
                ),
        
                const SizedBox(height: 6),
        
                TextField(
                  decoration: InputDecoration(
                    hintText: "johndoe123",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
        
                const SizedBox(height: 16),
        
                /// Password
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Password"),
                ),
        
                const SizedBox(height: 6),
        
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "••••••••",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
        
                const SizedBox(height: 8),
        
                /// Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Forgot Password?"),
                  ),
                ),
        
                /// Biometrics checkbox
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (v) {}),
                    const Text("Use biometrics for faster login"),
                  ],
                ),
        
                const SizedBox(height: 10),
        
                /// Sign in button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Sign In"),
                  ),
                ),
        
                const SizedBox(height: 10),
        
                /// Biometrics button
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.fingerprint),
                  label: const Text("Sign in with Biometrics"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
        
                const SizedBox(height: 16),
        
                /// Divider
                Row(
                  children: [
                    Expanded(child: Divider()),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Or continue with"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
        
                const SizedBox(height: 16),
        
                /// Social buttons
                Row(
                  children: [
                    Expanded(child: _socialButton("Google", Icons.g_mobiledata)),
                    const SizedBox(width: 10),
                    Expanded(child: _socialButton("Facebook", Icons.facebook)),
                  ],
                ),
        
                const SizedBox(height: 20),
        
                /// Terms
                const Text(
                  "By continuing, you agree to our Terms of Service and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabItem(String text, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String text, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
