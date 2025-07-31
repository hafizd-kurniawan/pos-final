import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/main_dashboard.dart';

void main() {
  runApp(const POSApp());
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Vehicle Management',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}