import 'package:flutter/material.dart';
import 'theme.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
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
                          size: 48,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      
                      // App Title
                      Text(
                        'POS Vehicle Management',
                        style: AppTextStyles.heading,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Modern Point of Sale System',
                        style: AppTextStyles.bodySmall,
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
                                    color: AppColors.white,
                                  ),
                                )
                              : const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      
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
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text('Admin: admin / admin123', style: AppTextStyles.bodySmall),
                            Text('Kasir: kasir1 / kasir123', style: AppTextStyles.bodySmall),
                            Text('Mekanik: mekanik1 / mekanik123', style: AppTextStyles.bodySmall),
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
    String? role;
    bool validCredentials = false;
    
    if (username == 'admin' && password == 'admin123') {
      role = 'Admin';
      validCredentials = true;
    } else if (username == 'kasir1' && password == 'kasir123') {
      role = 'Kasir';
      validCredentials = true;
    } else if (username.startsWith('mekanik') && password == 'mekanik123') {
      role = 'Mekanik';
      validCredentials = true;
    }

    setState(() {
      _isLoading = false;
    });

    if (validCredentials && role != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(userRole: role!),
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
        backgroundColor: AppColors.primary,
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