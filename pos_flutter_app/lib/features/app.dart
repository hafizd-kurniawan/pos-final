import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import '../core/constants/app_constants.dart';
import '../shared/providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'dashboard/kasir_dashboard_screen.dart';
import 'dashboard/mechanic_dashboard_screen.dart';
import 'dashboard/admin_dashboard_screen.dart';

class POSApp extends StatefulWidget {
  const POSApp({super.key});

  @override
  State<POSApp> createState() => _POSAppState();
}

class _POSAppState extends State<POSApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoginRoute = state.uri.path == '/login';

        // If not authenticated and not on login page, redirect to login
        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }

        // If authenticated and on login page, redirect to appropriate dashboard
        if (isAuthenticated && isLoginRoute) {
          final userRole = authProvider.currentUserRole;
          switch (userRole) {
            case AppConstants.roleAdmin:
              return '/admin-dashboard';
            case AppConstants.roleKasir:
              return '/kasir-dashboard';
            case AppConstants.roleMekanik:
              return '/mechanic-dashboard';
            default:
              return '/kasir-dashboard';
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
          path: '/kasir-dashboard',
          builder: (context, state) => const KasirDashboardScreen(),
        ),
        GoRoute(
          path: '/mechanic-dashboard',
          builder: (context, state) => const MechanicDashboardScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          theme: AppConfig.lightTheme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Scaffold(
              body: authProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : child,
            );
          },
        );
      },
    );
  }
}