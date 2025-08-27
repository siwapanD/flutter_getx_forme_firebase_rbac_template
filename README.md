# Flutter GetX Forme Firebase RBAC Template

A comprehensive, production-ready Flutter template with GetX + Forme + Firebase + RBAC + Testing architecture. This template provides a solid foundation for enterprise Flutter applications with authentication, role-based access control, and modern development practices.

## 🚀 Features

### Core Architecture
- **GetX State Management**: Reactive state management with dependency injection
- **Forme Forms**: Powerful form building and validation
- **Firebase Integration**: Authentication, Firestore, and real-time features
- **RBAC System**: Role-Based Access Control with permissions
- **Responsive Design**: 900px breakpoint with adaptive layouts
- **Material Design 3**: Modern UI with comprehensive theming
- **Testing Ready**: Unit, widget, and integration test infrastructure

### Authentication & Security
- ✅ Email/Password authentication
- ✅ Google Sign-In integration
- ✅ Apple Sign-In integration
- ✅ Email verification
- ✅ Password reset functionality
- ✅ Secure local storage with encryption
- ✅ JWT token management
- ✅ Biometric authentication support

### Role-Based Access Control (RBAC)
- ✅ Hierarchical role system (Guest → User → Manager → Admin → Super Admin)
- ✅ Permission-based access control
- ✅ Route-level security with middleware
- ✅ UI component-level access control
- ✅ Dynamic permission management

### UI/UX Features
- ✅ Responsive design (mobile, tablet, desktop)
- ✅ Light/Dark theme support
- ✅ Accessibility features
- ✅ Custom theming system
- ✅ Loading states and error handling
- ✅ Offline support indicators
- ✅ Form validation with real-time feedback

### Developer Experience
- ✅ Clean architecture with separation of concerns
- ✅ Type-safe Result pattern for error handling
- ✅ Memory-safe debouncing utilities
- ✅ Environment-based configuration
- ✅ Comprehensive logging
- ✅ Code documentation
- ✅ Linting and analysis rules

## 📱 Screenshots

### Desktop Layout (≥900px)
![Desktop Login](screenshots/desktop-login.png)
*Two-column responsive layout for larger screens*

### Mobile Layout (<900px)
![Mobile Login](screenshots/mobile-login.png)
*Single-column layout optimized for mobile devices*

## 🏗️ Project Structure

```
lib/
├── core/                           # Core application logic
│   ├── app.dart                   # App bootstrap
│   ├── bindings/                  # Dependency injection
│   ├── config/                    # Environment configuration
│   ├── constants/                 # App-wide constants
│   ├── routes/                    # Navigation and routing
│   ├── theme/                     # Theming system
│   └── utils/                     # Utilities (debouncer, result)
├── data/                          # Data layer
│   ├── models/                    # Data models
│   ├── providers/                 # Data providers (Firebase, Storage, Auth)
│   └── repositories/              # Data repositories
├── app/                          # Application layer
│   ├── modules/                   # Feature modules
│   │   ├── splash/               # Splash screen
│   │   ├── auth/                 # Authentication (login, register)
│   │   ├── dashboard/            # User dashboard
│   │   ├── admin/                # Admin features
│   │   └── profile/              # User profile
│   └── shared/                   # Shared components
│       ├── controllers/          # Global controllers
│       ├── middleware/           # Route middleware
│       ├── widgets/              # Reusable widgets
│       └── components/           # UI components
└── main.dart                     # Application entry point
```

## 🛠️ Setup Instructions

### Prerequisites
- Flutter 3.24.x or higher
- Dart 3.5.x or higher
- Firebase project (for authentication and database)
- iOS/Android development environment

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/flutter_getx_forme_firebase_rbac_template.git
cd flutter_getx_forme_firebase_rbac_template
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### 3.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Enable Authentication and Firestore Database

#### 3.2 Configure Firebase for Flutter
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

#### 3.3 Enable Authentication Providers
1. In Firebase Console, go to Authentication > Sign-in method
2. Enable Email/Password, Google, and Apple (if needed)
3. Configure OAuth redirect URIs as needed

#### 3.4 Setup Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admin users can read all user documents
    match /users/{userId} {
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'super_admin'];
    }
  }
}
```

### 4. Environment Configuration

Create environment-specific configuration files:

#### 4.1 Development
```bash
# Set development environment
export ENVIRONMENT=development
export ENABLE_FIREBASE=true
export ENABLE_DEBUG_LOGS=true
```

#### 4.2 Production
```bash
# Set production environment
export ENVIRONMENT=production
export ENABLE_FIREBASE=true
export ENABLE_DEBUG_LOGS=false
export ENABLE_ANALYTICS=true
```

### 5. Run the Application
```bash
# Development
flutter run --dart-define=ENVIRONMENT=development

# Production
flutter run --dart-define=ENVIRONMENT=production --release
```

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run unit tests
flutter test test/unit/

# Run widget tests
flutter test test/widget/

# Run integration tests
flutter test integration_test/
```

### Test Coverage
```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🏢 Enterprise Features

### User Roles & Permissions

| Role | Permissions | Description |
|------|-------------|-------------|
| **Guest** | Read | Unauthenticated users |
| **User** | Read, Write | Standard authenticated users |
| **Manager** | Read, Write, View Reports | Team managers |
| **Admin** | Read, Write, Delete, Manage Users, View Reports | System administrators |
| **Super Admin** | All permissions | Full system access |

### Security Features
- **Route Protection**: Middleware-based route security
- **Data Encryption**: Sensitive data encryption at rest
- **Session Management**: Secure token handling with refresh
- **Input Validation**: Comprehensive form validation
- **SQL Injection Protection**: Firestore security rules
- **XSS Prevention**: Input sanitization

### Performance Optimizations
- **Lazy Loading**: Controllers and dependencies
- **Memory Management**: Proper disposal patterns
- **Caching**: Intelligent data caching strategies
- **Debouncing**: Input debouncing to prevent excessive API calls
- **Image Optimization**: Automatic image compression

## 🎨 Customization

### Theming
```dart
// Customize app theme in lib/core/theme/app_theme.dart
static const ColorScheme _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF1976D2),        // Your brand color
  onPrimary: Color(0xFFFFFFFF),
  // ... other colors
);
```

### Constants
```dart
// Update app constants in lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'Your App Name';
  static const String organizationName = 'Your Organization';
  // ... other constants
}
```

### Environment Configuration
```dart
// Modify environment settings in lib/core/config/env.dart
static String get apiBaseUrl {
  switch (_environment) {
    case 'development':
      return 'https://your-dev-api.com';
    case 'production':
      return 'https://your-api.com';
    // ...
  }
}
```

## 📋 Available Scripts

### Development
```bash
# Start development server
flutter run --dart-define=ENVIRONMENT=development

# Build for development
flutter build apk --dart-define=ENVIRONMENT=development

# Analyze code
flutter analyze

# Format code
dart format .
```

### Production
```bash
# Build Android APK
flutter build apk --release --dart-define=ENVIRONMENT=production

# Build Android App Bundle
flutter build appbundle --release --dart-define=ENVIRONMENT=production

# Build iOS
flutter build ios --release --dart-define=ENVIRONMENT=production
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the existing code style and patterns
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR
- Use conventional commit messages

## 📚 Documentation

### Architecture Documentation
- [State Management](docs/state-management.md)
- [Authentication Flow](docs/authentication.md)
- [RBAC Implementation](docs/rbac.md)
- [Testing Strategy](docs/testing.md)
- [Deployment Guide](docs/deployment.md)

### API Documentation
- [Data Models](docs/api/models.md)
- [Repositories](docs/api/repositories.md)
- [Controllers](docs/api/controllers.md)

## 🔧 Troubleshooting

### Common Issues

#### Firebase Configuration
```bash
# If Firebase is not initialized
flutter clean
flutter pub get
flutterfire configure
```

#### Build Issues
```bash
# Clear build cache
flutter clean
flutter pub get
flutter pub deps

# Rebuild
flutter build apk
```

#### Dependency Conflicts
```bash
# Update dependencies
flutter pub upgrade
flutter pub get
```

### Getting Help
- Check [Issues](https://github.com/your-repo/issues) for known problems
- Join our [Discord](https://discord.gg/your-server) for community support
- Read the [FAQ](docs/faq.md) for common questions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [GetX](https://pub.dev/packages/get) for state management
- [Forme](https://pub.dev/packages/forme) for form handling
- [Firebase](https://firebase.google.com/) for backend services
- [Flutter](https://flutter.dev/) team for the amazing framework

## 🗺️ Roadmap

- [ ] Advanced user management interface
- [ ] Real-time notifications
- [ ] Offline-first data synchronization
- [ ] Advanced analytics dashboard
- [ ] Multi-tenant support
- [ ] Plugin system for extensibility
- [ ] CI/CD pipeline templates
- [ ] Docker deployment support

---

**Note**: This template is designed for enterprise applications and includes comprehensive security, testing, and architectural patterns. Customize it according to your specific requirements.

For questions or support, please [open an issue](https://github.com/your-repo/issues) or reach out to our community.
