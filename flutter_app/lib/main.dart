import 'package:flutter/material.dart';
import 'core/services/api_service.dart';
import 'features/auth/services/auth_service.dart';
import 'theme.dart';
import 'features/auth/screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service
  await ApiService().init();
  
  runApp(const POSApp());
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Vehicle Management',
      theme: AppTheme.theme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}