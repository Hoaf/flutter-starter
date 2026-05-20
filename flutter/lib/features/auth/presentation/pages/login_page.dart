import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_demo/di/service_locator.dart';
import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter_demo/presentation/config/app_font_sizes.dart';
import 'package:flutter_demo/presentation/routes/routers.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_bloc.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_event.dart';
import 'package:flutter_demo/features/auth/presentation/bloc/login_state.dart';
import 'package:flutter_demo/presentation/screens/widgets/buttons/flat_button.dart';
import 'package:flutter_demo/presentation/screens/widgets/snackbars/app_snackbars.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  int _activeTab = 0;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _useBiometrics = false;

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  void _updateStatusBar(int index) {
    if (index == 0) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );
    }
  }

  @override
  void initState() {
    _termsRecognizer = TapGestureRecognizer()..onTap = () {};
    _privacyRecognizer = TapGestureRecognizer()..onTap = () {};
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
          } else if (state is LoginFailure) {
            AppSnackBars.showDangerSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;
          return Scaffold(
            backgroundColor: AppColors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Icon circle
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.cyanLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('🛍️', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.shark,
                        fontFamily: 'Ubuntu',
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Please enter your details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppFontSizes.fs_12,
                        color: AppColors.paleSky,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tab switcher
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _tabItem('Login', 0),
                          _tabItem('Sign Up', 1),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Username',
                      style: TextStyle(
                        fontSize: AppFontSizes.fs_12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 6),

                    TextField(
                      controller: _usernameController,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'johndoe123',
                        hintStyle:
                            const TextStyle(color: Color(0xFFBDBDBD)),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.gray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.cyan, width: 1.5),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.gray),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: AppFontSizes.fs_12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 6),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle:
                            const TextStyle(color: Color(0xFFBDBDBD)),
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.gray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.cyan, width: 1.5),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.gray),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.paleSky,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.cyan,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forget Password?',
                          style: TextStyle(fontSize: AppFontSizes.fs_12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Biometrics checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _useBiometrics,
                          onChanged: isLoading
                              ? null
                              : (v) => setState(
                                  () => _useBiometrics = v ?? false),
                          activeColor: AppColors.cyan,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const Text(
                          'Use biometrics for faster login',
                          style: TextStyle(
                            fontSize: AppFontSizes.fs_12,
                            color: AppColors.paleSky,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Sign In button
                    FlatButton(
                      isLoading ? 'Signing in...' : 'Sign In',
                      backgroundColor: AppColors.cyan,
                      borderRadius: 10,
                      titleSize: AppFontSizes.fs_15,
                      isBold: true,
                      leadingIcon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white),
                              ),
                            )
                          : null,
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<LoginBloc>().add(
                                    LoginSubmitEvent(
                                      username: _usernameController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                            },
                    ),

                    const SizedBox(height: 14),

                    // Biometrics button
                    OutlinedButton(
                      onPressed: isLoading ? null : () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.cyan),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '⚡ Sign in with Biometrics',
                        style: TextStyle(
                          fontSize: AppFontSizes.fs_12,
                          color: Color(0xFF616161),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: AppColors.gray)),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              fontSize: AppFontSizes.fs_12,
                              color: AppColors.paleSky,
                            ),
                          ),
                        ),
                        const Expanded(
                            child: Divider(color: AppColors.gray)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Social buttons
                    Row(
                      children: [
                        Expanded(
                          child: _socialButton(
                              'Google', 'G', const Color(0xFFDB4437)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _socialButton(
                              'Facebook', 'f', const Color(0xFF1877F2)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Footer
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: AppFontSizes.fs_10,
                          color: AppColors.paleSky,
                          fontFamily: 'Ubuntu',
                        ),
                        children: [
                          const TextSpan(
                              text: 'By continuing, you agree to our '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: _termsRecognizer,
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: _privacyRecognizer,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tabItem(String text, int index) {
    final bool active = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _activeTab = index);
          _updateStatusBar(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: AppFontSizes.fs_14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? AppColors.shark : AppColors.paleSky,
                fontFamily: 'Ubuntu',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(
      String label, String iconLetter, Color iconColor) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.gray),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            iconLetter,
            style: TextStyle(
              fontSize: AppFontSizes.fs_16,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppFontSizes.fs_14,
              color: AppColors.shark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
