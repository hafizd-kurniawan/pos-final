import 'package:flutter/material.dart';

/// Design System Constants for POS App
/// Following Material Design 3 with elegant 2-color scheme
class AppColors {
  // Primary Color Scheme (Blue)
  static const Color primary = Color(0xFF2563EB);           // Blue-600
  static const Color primaryLight = Color(0xFF3B82F6);      // Blue-500  
  static const Color primaryDark = Color(0xFF1E40AF);       // Blue-700
  static const Color primaryContainer = Color(0xFFEFF6FF);  // Blue-50
  
  // Secondary Color Scheme (Gray/Slate)
  static const Color secondary = Color(0xFF64748B);         // Slate-500
  static const Color secondaryLight = Color(0xFF94A3B8);    // Slate-400
  static const Color secondaryDark = Color(0xFF475569);     // Slate-600
  static const Color secondaryContainer = Color(0xFFF8FAFC); // Slate-50
  
  // Neutral Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);    // Slate-100
  static const Color background = Color(0xFFFAFAFA);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF0F172A);         // Slate-900
  static const Color onBackground = Color(0xFF1E293B);      // Slate-800
  
  // Status Colors (minimal usage)
  static const Color success = Color(0xFF059669);           // Green-600
  static const Color warning = Color(0xFFD97706);           // Orange-600
  static const Color error = Color(0xFFDC2626);             // Red-600
  
  // Card and component colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE2E8F0);           // Slate-200
  static const Color border = Color(0xFFCBD5E1);            // Slate-300
}

/// Typography System
class AppTextStyles {
  static const String fontFamily = 'Roboto';
  
  // Headlines
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.3,
  );
  
  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    height: 1.4,
  );
  
  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.secondary,
    height: 1.4,
  );
  
  // Labels and buttons
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
    height: 1.4,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
    height: 1.3,
  );
  
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );
}

/// Spacing and Layout Constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Grid system for 4-column layout
  static const double gridPadding = 16.0;
  static const double gridSpacing = 12.0;
  static const int gridColumns = 4;
}

/// Border Radius Constants
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  
  static const BorderRadius small = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(md));
  static const BorderRadius large = BorderRadius.all(Radius.circular(lg));
}

/// Shadow Constants
class AppShadows {
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow elevatedShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
  
  static const List<BoxShadow> card = [cardShadow];
  static const List<BoxShadow> elevated = [elevatedShadow];
}

/// Icon Sizes
class AppIconSizes {
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
}

/// Responsive Breakpoints
class AppBreakpoints {
  static const double mobile = 640;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1280;
}