import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/models.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/mobile_app.dart';

void main() {
  runApp(const SubSplitApp());
}

class SubSplitApp extends StatefulWidget {
  const SubSplitApp({super.key});

  @override
  State<SubSplitApp> createState() => _SubSplitAppState();
}

class _SubSplitAppState extends State<SubSplitApp> {
  _AppState _state = _AppState.splash;
  AppUser? _currentUser;

  void _onSplashComplete() {
    setState(() => _state = _AppState.onboarding);
  }

  void _onOnboardingComplete() {
    setState(() => _state = _AppState.login);
  }

  void _handleLogin(AppUser user) {
    setState(() {
      _currentUser = user;
      _state = _AppState.app;
    });
  }

  void _handleLogout() {
    setState(() {
      _currentUser = null;
      _state = _AppState.login;
    });
  }

  void _goToRegister() {
    setState(() => _state = _AppState.register);
  }

  void _goToLogin() {
    setState(() => _state = _AppState.login);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubSplit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_state) {
      case _AppState.splash:
        return SplashScreen(onComplete: _onSplashComplete);
      case _AppState.onboarding:
        return OnboardingScreen(onComplete: _onOnboardingComplete);
      case _AppState.login:
        return LoginScreen(
          onLogin: _handleLogin,
          onGoToRegister: _goToRegister,
        );
      case _AppState.register:
        return RegisterScreen(
          onRegister: _handleLogin,
          onBackToLogin: _goToLogin,
        );
      case _AppState.app:
        return MobileApp(
          currentUser: _currentUser!,
          onLogout: _handleLogout,
        );
    }
  }
}

enum _AppState { splash, onboarding, login, register, app }
