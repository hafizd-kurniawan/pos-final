import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/api_constants.dart';
import 'features/dashboard/screens/simple_dashboard.dart';

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
      home: const SimpleLoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Simplified login screen for testing
class SimpleLoginScreen extends StatefulWidget {
  const SimpleLoginScreen({super.key});

  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        size: AppIconSizes.xl,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    Text(
                      'POS Vehicle Management',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Modern Point of Sale System',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Username Field
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'admin, kasir1, or mekanik1',
                      ),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        hintText: 'admin123, kasir123, or mekanik123',
                      ),
                      enabled: !_isLoading,
                      onSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Test credentials info
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Credentials:',
                            style: AppTextStyles.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text('Admin: admin / admin123'),
                          const Text('Kasir: kasir1 / kasir123'),
                          const Text('Mekanik: mekanik1 / mekanik123'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    final username = _usernameController.text.toLowerCase().trim();
    final password = _passwordController.text.trim();
    
    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter username and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple credential validation
    UserRole? role;
    bool validCredentials = false;
    
    if (username == 'admin' && password == 'admin123') {
      role = UserRole.admin;
      validCredentials = true;
    } else if (username == 'kasir1' && password == 'kasir123') {
      role = UserRole.kasir;
      validCredentials = true;
    } else if (username.startsWith('mekanik') && password == 'mekanik123') {
      role = UserRole.mekanik;
      validCredentials = true;
    }

    setState(() {
      _isLoading = false;
    });

    if (validCredentials && role != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SimpleDashboard(userRole: role!),
        ),
      );
    } else {
      _showSnackBar('Invalid credentials. Please use test credentials.');
    }
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}