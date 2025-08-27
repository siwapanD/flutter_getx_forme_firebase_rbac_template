import 'package:flutter/material.dart';

/// App-wide constants to avoid hardcoding values
/// 
/// This class contains all the constant values used throughout the application
/// including app metadata, configuration values, and UI constants.
abstract class AppConstants {
  // App metadata
  static const String appName = 'Flutter GetX Template';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appDescription = 'Comprehensive Flutter template with GetX + Forme + Firebase + RBAC + Testing';
  
  // Company/Organization info
  static const String organizationName = 'Your Organization';
  static const String organizationUrl = 'https://your-organization.com';
  static const String supportEmail = 'support@your-organization.com';
  
  // Localization
  static const Locale defaultLocale = Locale('en', 'US');
  static const Locale fallbackLocale = Locale('en', 'US');
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('es', 'ES'), // Spanish
    Locale('fr', 'FR'), // French
    Locale('de', 'DE'), // German
    Locale('ja', 'JP'), // Japanese
    Locale('ko', 'KR'), // Korean
    Locale('zh', 'CN'), // Chinese Simplified
  ];
  
  // API Configuration
  static const String apiBaseUrl = 'https://api.your-app.com';
  static const String apiVersion = 'v1';
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  
  // Storage keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyUser = 'user_data';
  static const String storageKeyTheme = 'theme_mode';
  static const String storageKeyLanguage = 'selected_language';
  static const String storageKeyOnboarding = 'onboarding_completed';
  static const String storageKeyPermissions = 'user_permissions';
  static const String storageKeySettings = 'app_settings';
  
  // Authentication
  static const int tokenExpiryHours = 24;
  static const int refreshTokenExpiryDays = 30;
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 30;
  
  // User roles (RBAC)
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleUser = 'user';
  static const String roleGuest = 'guest';
  
  static const List<String> allRoles = [
    roleSuperAdmin,
    roleAdmin,
    roleManager,
    roleUser,
    roleGuest,
  ];
  
  // Permissions
  static const String permissionRead = 'read';
  static const String permissionWrite = 'write';
  static const String permissionDelete = 'delete';
  static const String permissionAdmin = 'admin';
  static const String permissionManageUsers = 'manage_users';
  static const String permissionManageRoles = 'manage_roles';
  static const String permissionViewReports = 'view_reports';
  static const String permissionExportData = 'export_data';
  
  // UI Constants
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
  
  // Animation durations
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  // Network timeouts
  static const Duration networkTimeoutShort = Duration(seconds: 10);
  static const Duration networkTimeoutMedium = Duration(seconds: 30);
  static const Duration networkTimeoutLong = Duration(seconds: 60);
  
  // Debounce durations
  static const Duration debounceSearch = Duration(milliseconds: 500);
  static const Duration debounceInput = Duration(milliseconds: 300);
  static const Duration debounceButton = Duration(milliseconds: 1000);
  
  // Validation constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxDisplayNameLength = 50;
  static const int maxBioLength = 500;
  
  // File upload constants
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt'];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int minPageSize = 5;
  
  // Cache constants
  static const Duration cacheExpiryShort = Duration(minutes: 5);
  static const Duration cacheExpiryMedium = Duration(hours: 1);
  static const Duration cacheExpiryLong = Duration(days: 1);
  
  // Notification constants
  static const String notificationChannelGeneral = 'general';
  static const String notificationChannelSecurity = 'security';
  static const String notificationChannelUpdates = 'updates';
  
  // Error messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorTimeout = 'Request timed out. Please try again.';
  static const String errorUnauthorized = 'You are not authorized to perform this action.';
  static const String errorForbidden = 'Access denied. Insufficient permissions.';
  static const String errorNotFound = 'The requested resource was not found.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorValidation = 'Please check your input and try again.';
  
  // Success messages
  static const String successLogin = 'Successfully logged in!';
  static const String successLogout = 'Successfully logged out!';
  static const String successRegister = 'Account created successfully!';
  static const String successUpdate = 'Updated successfully!';
  static const String successDelete = 'Deleted successfully!';
  static const String successSave = 'Saved successfully!';
  
  // Form validation messages
  static const String validationRequired = 'This field is required';
  static const String validationEmailInvalid = 'Please enter a valid email address';
  static const String validationPasswordTooShort = 'Password must be at least 8 characters';
  static const String validationPasswordsDoNotMatch = 'Passwords do not match';
  static const String validationUsernameTooShort = 'Username must be at least 3 characters';
  static const String validationPhoneInvalid = 'Please enter a valid phone number';
  
  // Date/Time formats
  static const String dateFormatDefault = 'MMM dd, yyyy';
  static const String dateFormatShort = 'MM/dd/yyyy';
  static const String dateFormatLong = 'EEEE, MMMM dd, yyyy';
  static const String timeFormatDefault = 'hh:mm a';
  static const String timeFormat24Hour = 'HH:mm';
  static const String dateTimeFormatDefault = 'MMM dd, yyyy hh:mm a';
  
  // Feature flags (for testing and gradual rollouts)
  static const String featureFlagNewDashboard = 'new_dashboard';
  static const String featureFlagEnhancedSecurity = 'enhanced_security';
  static const String featureFlagBetaFeatures = 'beta_features';
  static const String featureFlagOfflineMode = 'offline_mode';
  
  // Environment-specific constants
  static const String environmentDevelopment = 'development';
  static const String environmentStaging = 'staging';
  static const String environmentProduction = 'production';
  
  // Social login providers
  static const String providerGoogle = 'google';
  static const String providerApple = 'apple';
  static const String providerFacebook = 'facebook';
  static const String providerGitHub = 'github';
  
  // App URLs
  static const String privacyPolicyUrl = 'https://your-app.com/privacy';
  static const String termsOfServiceUrl = 'https://your-app.com/terms';
  static const String helpUrl = 'https://your-app.com/help';
  static const String aboutUrl = 'https://your-app.com/about';
  
  // Development and debugging
  static const bool enableDebugLogs = true;
  static const bool enablePerformanceMonitoring = true;
  static const bool enableCrashReporting = true;
  
  /// Get role hierarchy for RBAC comparison
  static int getRoleHierarchy(String role) {
    switch (role) {
      case roleSuperAdmin:
        return 100;
      case roleAdmin:
        return 80;
      case roleManager:
        return 60;
      case roleUser:
        return 40;
      case roleGuest:
        return 20;
      default:
        return 0;
    }
  }
  
  /// Check if role has sufficient privileges
  static bool hasRolePrivilege(String userRole, String requiredRole) {
    return getRoleHierarchy(userRole) >= getRoleHierarchy(requiredRole);
  }
  
  /// Get default permissions for a role
  static List<String> getDefaultPermissions(String role) {
    switch (role) {
      case roleSuperAdmin:
        return [
          permissionRead,
          permissionWrite,
          permissionDelete,
          permissionAdmin,
          permissionManageUsers,
          permissionManageRoles,
          permissionViewReports,
          permissionExportData,
        ];
      case roleAdmin:
        return [
          permissionRead,
          permissionWrite,
          permissionDelete,
          permissionManageUsers,
          permissionViewReports,
          permissionExportData,
        ];
      case roleManager:
        return [
          permissionRead,
          permissionWrite,
          permissionViewReports,
        ];
      case roleUser:
        return [
          permissionRead,
          permissionWrite,
        ];
      case roleGuest:
        return [
          permissionRead,
        ];
      default:
        return [];
    }
  }
}