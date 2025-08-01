import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/constants/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/vehicle_provider.dart';
import 'shared/providers/customer_provider.dart';
import 'shared/providers/notification_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/admin_dashboard.dart';
import 'features/dashboard/screens/kasir_dashboard.dart';
import 'features/dashboard/screens/mechanic_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await StorageService.init();
  
  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'POS Flutter',
            theme: AppTheme.lightTheme,
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.subloc == '/login';

        // If not logged in and not on login page, redirect to login
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        // If logged in and on login page, redirect to appropriate dashboard
        if (isLoggedIn && isLoggingIn) {
          switch (authProvider.user?.role) {
            case 'admin':
              return '/admin-dashboard';
            case 'kasir':
              return '/kasir-dashboard';
            case 'mekanik':
              return '/mechanic-dashboard';
            default:
              return '/login';
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => const AdminDashboard(),
        ),
        GoRoute(
          path: '/kasir-dashboard',
          builder: (context, state) => const KasirDashboard(),
        ),
        GoRoute(
          path: '/mechanic-dashboard',
          builder: (context, state) => const MechanicDashboard(),
        ),
      ],
    );
  }
}