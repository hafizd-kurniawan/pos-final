# POS Flutter App

A modern, responsive Flutter application for Vehicle Sales & Repair Management system. This app integrates with the Go backend API to provide a complete POS solution.

## Features

### ✅ Implemented Features
- **Clean Material Design**: Elegant blue & gray color scheme
- **Responsive Layout**: 4-column grid on tablets, 2-column on mobile
- **Authentication**: JWT-based login with role detection
- **Role-based Dashboards**: Separate interfaces for Admin, Kasir, and Mekanik
- **Vehicle Management**: Grid view with photo thumbnails and filtering
- **Professional UI**: Sidebar navigation and modern card layouts
- **State Management**: Provider pattern for reactive UI
- **API Integration**: Ready for Go backend integration

### 🔄 In Development
- Sales flow with PDF generation
- Purchase management with mandatory photos
- Customer management CRUD
- Work order system for mechanics
- Real-time notifications
- Offline data caching
- Reports and analytics

## Project Structure

```
lib/
├── core/
│   ├── config/           # App configuration and themes
│   ├── constants/        # App constants and theme definitions
│   ├── services/         # API, Auth, and Storage services
│   └── widgets/          # Reusable widgets (Dashboard, Cards, etc.)
├── features/
│   ├── auth/            # Login and authentication screens
│   ├── dashboard/       # Role-based dashboard screens
│   └── vehicles/        # Vehicle management screens
└── shared/
    ├── models/          # Data models (User, Vehicle, Customer, etc.)
    ├── providers/       # State management providers
    └── repositories/    # Data access layer
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.13.0 or later)
- Dart SDK (3.1.0 or later)
- Android Studio / VS Code with Flutter extensions
- Go backend API running (see main project README)

### Installation

1. **Clone the repository** (if not already done):
   ```bash
   git clone <repository-url>
   cd pos-final/pos_flutter_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**:
   Edit `lib/core/constants/app_constants.dart`:
   ```dart
   static const String apiBaseUrl = 'http://your-backend-url:8080/api/v1';
   ```

4. **Run the app**:
   ```bash
   # For development
   flutter run
   
   # For web
   flutter run -d chrome
   
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   ```

### Demo Credentials

Use these credentials to test different user roles:

- **Admin**: `admin` / `password`
- **Kasir**: `kasir` / `password`  
- **Mekanik**: `mekanik` / `password`

## API Integration

The app is designed to work with the Go backend API. Key endpoints:

### Authentication
- `POST /auth/login` - User login
- `GET /auth/profile` - Get user profile
- `POST /auth/refresh` - Refresh token

### Vehicles
- `GET /vehicles` - List vehicles with filtering
- `POST /vehicles` - Create new vehicle
- `GET /vehicles/:id` - Get vehicle details
- `POST /files/vehicles/:id/photo` - Upload vehicle photos

### Sales & Purchases
- `GET /sales` - List sales invoices
- `POST /sales` - Create new sale
- `GET /pdf/sales/:id` - Generate PDF invoice

## Configuration

### Theme Customization
Edit `lib/core/constants/app_theme.dart` to customize:
- Colors (primary, secondary, status colors)
- Typography (font family, text styles)
- Spacing and border radius

### API Configuration
Edit `lib/core/constants/app_constants.dart` to modify:
- API base URL
- File upload limits
- Pagination settings
- Cache duration

## Development Guidelines

### State Management
- Use Provider pattern for app-wide state
- Individual providers for different features (Auth, Vehicle, etc.)
- Keep providers focused and single-responsibility

### File Organization
- Group by feature, not by file type
- Keep related screens and widgets together
- Use barrel exports for clean imports

### UI/UX Principles
- Mobile-first responsive design
- Consistent spacing using AppSpacing constants
- Material Design 3 components
- Accessibility support
- Error handling with user-friendly messages

## Build & Deployment

### Development Build
```bash
flutter build apk --debug
flutter build web --debug
```

### Production Build
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Environment Configuration
Create different configurations for dev/staging/production:
- Separate API endpoints
- Different app names/icons
- Build flavors for multi-environment support

## Dependencies

### Key Packages
- **provider**: State management
- **go_router**: Navigation and routing
- **http/dio**: HTTP client for API calls
- **cached_network_image**: Image caching
- **image_picker**: Photo selection
- **shared_preferences**: Local storage
- **jwt_decoder**: JWT token handling

### Development Tools
- **flutter_lints**: Code linting
- **build_runner**: Code generation

## Contributing

1. Follow Flutter/Dart style guide
2. Write meaningful commit messages
3. Test on multiple screen sizes
4. Ensure proper error handling
5. Update documentation for new features

## Troubleshooting

### Common Issues

**API Connection Issues**:
- Verify backend is running
- Check API endpoint URL
- Ensure proper CORS configuration

**Build Issues**:
- Run `flutter clean && flutter pub get`
- Update Flutter/Dart SDK
- Check dependency versions

**Image Loading Issues**:
- Verify file upload endpoint
- Check network permissions
- Ensure proper image URLs

## License

This project is part of the POS Final system. See main project for license details.