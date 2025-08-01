# Flutter POS System

A comprehensive Point of Sale (POS) system for vehicle sales, repairs, and spare parts management built with Flutter and integrated with the Go backend API.

## 🎯 Features

### 🔐 Authentication & Role Management
- JWT-based authentication with auto-refresh
- Role-based access control (Admin, Kasir, Mekanik)
- Secure login with demo credentials
- User profile management

### 📱 Modern UI/UX Design
- Clean Material Design 3 with elegant 2-color scheme
- Responsive layout with 4-column grid for tablets
- Professional sidebar navigation
- Touch-friendly interfaces with proper spacing
- Loading states and comprehensive error handling

### 🚗 Vehicle Management
- Responsive vehicle grid with photo thumbnails
- Advanced search and filtering capabilities
- Mandatory photo upload for all vehicles
- Vehicle status tracking (Available, In Repair, Sold, Reserved)
- Comprehensive vehicle details with photo gallery

### 👥 Customer Management
- Customer grid with responsive design
- Complete CRUD operations
- Advanced search by name, phone, or email
- Customer contact information management
- Transaction history tracking

### 📊 Dashboard Analytics
- Role-specific dashboard views
- Real-time statistics and KPIs
- Quick overview cards
- Notification center with unread count

## 🏗️ Architecture

### State Management
- Provider pattern for reactive UI updates
- Separate providers for different features
- Clean separation of concerns
- Proper error handling and loading states

### API Integration
- HTTP client with automatic authentication
- Token refresh mechanism
- File upload support for photos
- Comprehensive error handling

### Data Layer
- Repository pattern for clean data access
- Local storage with cache management
- Offline capability with queue system
- Secure token storage

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/           # App configuration
│   ├── constants/        # Themes and constants
│   ├── services/         # API, Auth, Storage services
│   └── widgets/          # Reusable widgets
├── features/
│   ├── auth/            # Authentication screens
│   ├── dashboard/       # Role-based dashboards
│   ├── vehicles/        # Vehicle management
│   ├── customers/       # Customer management
│   ├── sales/           # Sales management
│   ├── purchases/       # Purchase management
│   ├── work_orders/     # Work order system
│   ├── spare_parts/     # Inventory management
│   └── reports/         # Analytics & reporting
└── shared/
    ├── models/          # Data models
    ├── providers/       # State management
    └── repositories/    # Data access layer
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.16.0 or higher)
- Dart SDK (3.0.0 or higher)
- Go backend API running on localhost:8080

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pos-final/flutter_pos
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   - Update `lib/core/config/app_config.dart`
   - Set the correct `baseUrl` for your Go backend

4. **Run the application**
   ```bash
   flutter run
   ```

### Demo Credentials

| Role     | Username | Password   | Description                    |
|----------|----------|------------|--------------------------------|
| Admin    | admin    | admin123   | Full system access             |
| Kasir    | kasir1   | kasir123   | Sales and customer management  |
| Mekanik  | mekanik1 | mekanik123 | Work orders and parts          |

## 🎨 Design System

### Color Scheme
- **Primary**: #2563EB (Elegant Blue)
- **Secondary**: #64748B (Professional Gray)
- **Success**: #059669 (Green)
- **Warning**: #D97706 (Orange)
- **Error**: #DC2626 (Red)

### Typography
- **Font Family**: Inter
- **Consistent text styles** for titles, body text, and labels
- **Proper contrast** for accessibility

### Components
- Professional cards with subtle elevation
- Responsive grids with proper spacing
- Touch-friendly buttons and form elements
- Status badges with color coding

## 📱 Responsive Design

### Breakpoints
- **Desktop/Tablet Landscape**: 4-column grid (1200px+)
- **Tablet Portrait**: 3-column grid (800px+)
- **Large Phone**: 2-column grid (600px+)
- **Phone Portrait**: 1-column grid (<600px)

### Features
- Adaptive layouts for all screen sizes
- Touch-optimized for mobile and tablet
- Proper safe area handling
- Accessibility support

## 🔧 API Integration

### Endpoints Used
- **Authentication**: `/api/v1/auth/*`
- **Vehicles**: `/api/v1/vehicles/*`
- **Customers**: `/api/v1/customers/*`
- **Sales**: `/api/v1/sales/*`
- **Purchases**: `/api/v1/purchases/*`
- **Work Orders**: `/api/v1/work-orders/*`
- **Notifications**: `/api/v1/notifications/*`

### Features
- Automatic JWT token management
- File upload for vehicle photos
- Real-time data synchronization
- Offline capability with queue system

## 🎯 Business Flows

### Kasir (Cashier) Flow
1. **Vehicle Management**: Add vehicles with mandatory photos
2. **Customer Management**: Manage customer database
3. **Sales Process**: Select customer → Choose vehicle → Process payment
4. **Purchase Process**: Record vehicle purchases with documentation

### Mechanic Flow
1. **Work Orders**: View assigned repair tasks
2. **Parts Management**: Track spare parts usage
3. **Progress Updates**: Update work status with photos
4. **Completion**: Mark jobs complete with final costs

### Admin Flow
1. **System Overview**: Monitor all activities
2. **User Management**: Manage system users
3. **Analytics**: View comprehensive reports
4. **Settings**: Configure system parameters

## 🔄 State Management

### Providers
- **AuthProvider**: User authentication and profile
- **VehicleProvider**: Vehicle data and operations
- **CustomerProvider**: Customer management
- **NotificationProvider**: Real-time notifications

### Features
- Reactive UI updates
- Loading and error states
- Data caching and persistence
- Optimistic updates

## 🛠️ Development

### Code Style
- Follows Flutter/Dart conventions
- Consistent naming and structure
- Comprehensive documentation
- Proper error handling

### Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows
- API mocking for offline testing

## 🚢 Deployment

### Build Commands
```bash
# Android APK
flutter build apk --release

# iOS App Store
flutter build ipa --release

# Web deployment
flutter build web --release
```

### Environment Configuration
- Development: Local API server
- Staging: Staging API environment
- Production: Production API with HTTPS

## 📊 Performance

### Optimizations
- Image caching with CachedNetworkImage
- Lazy loading for large lists
- Efficient state management
- Proper memory management

### Monitoring
- Error tracking and reporting
- Performance metrics
- User analytics
- Crash reporting

## 🔒 Security

### Features
- Secure JWT token storage
- Input validation and sanitization
- Proper error message handling
- HTTPS communication

### Best Practices
- No sensitive data in logs
- Secure local storage
- Proper session management
- Input validation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the API integration guide

## 🎉 Acknowledgments

- Flutter team for the excellent framework
- Material Design team for the design system
- Community contributors and feedback