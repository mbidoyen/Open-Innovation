import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/models.dart';
import 'screens/login_screen.dart';
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
  AppUser? _currentUser;

  void _handleLogin(AppUser user) {
    setState(() => _currentUser = user);
  }

  void _handleLogout() {
    setState(() => _currentUser = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubSplit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: _currentUser == null
          ? LoginScreen(onLogin: _handleLogin)
          : MobileApp(
              currentUser: _currentUser!,
              onLogout: _handleLogout,
            ),
    );
  }
}
