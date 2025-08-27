import 'package:flutter/foundation.dart';

/// Environment-specific configuration
/// 
/// This class manages environment-specific settings and configurations
/// for different deployment environments (development, staging, production).
abstract class Env {
  // Private constructor to prevent instantiation
  Env._();
  
  /// Current environment
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  /// Firebase configuration
  static const bool _enableFirebase = bool.fromEnvironment(
    'ENABLE_FIREBASE',
    defaultValue: true,
  );
  
  /// API configuration
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.yourapp.com',
  );
  
  /// Debug configuration
  static const bool _enableDebugLogs = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGS',
    defaultValue: true,
  );
  
  /// Analytics configuration
  static const bool _enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );
  
  /// Crash reporting configuration
  static const bool _enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: true,
  );
  
  // Environment getters
  static String get environment => _environment;
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';
  static bool get isTest => _environment == 'test';
  
  // Feature flags
  static bool get enableFirebase => _enableFirebase && !isTest;
  static bool get enableDebugLogs => _enableDebugLogs || isDevelopment;
  static bool get enableAnalytics => _enableAnalytics && !isTest;
  static bool get enableCrashReporting => _enableCrashReporting && !isTest;
  
  // API configuration
  static String get apiBaseUrl {
    switch (_environment) {
      case 'development':
        return 'https://dev-api.yourapp.com';
      case 'staging':
        return 'https://staging-api.yourapp.com';
      case 'production':
        return 'https://api.yourapp.com';
      case 'test':
        return 'https://mock-api.yourapp.com';
      default:
        return _apiBaseUrl;
    }
  }
  
  // Firebase project configuration
  static String get firebaseProjectId {
    switch (_environment) {
      case 'development':
        return 'your-app-dev';
      case 'staging':
        return 'your-app-staging';
      case 'production':
        return 'your-app-prod';
      case 'test':
        return 'your-app-test';
      default:
        return 'your-app-dev';
    }
  }
  
  // App configuration
  static String get appName {
    switch (_environment) {
      case 'development':
        return 'YourApp (Dev)';
      case 'staging':
        return 'YourApp (Staging)';
      case 'production':
        return 'YourApp';
      case 'test':
        return 'YourApp (Test)';
      default:
        return 'YourApp';
    }
  }
  
  // Bundle/Package ID configuration
  static String get bundleId {
    switch (_environment) {
      case 'development':
        return 'com.yourapp.dev';
      case 'staging':
        return 'com.yourapp.staging';
      case 'production':
        return 'com.yourapp';
      case 'test':
        return 'com.yourapp.test';
      default:
        return 'com.yourapp.dev';
    }
  }
  
  // Database configuration
  static String get databaseUrl {
    switch (_environment) {
      case 'development':
        return 'https://your-app-dev-default-rtdb.firebaseio.com/';
      case 'staging':
        return 'https://your-app-staging-default-rtdb.firebaseio.com/';
      case 'production':
        return 'https://your-app-prod-default-rtdb.firebaseio.com/';
      case 'test':
        return 'https://mock-database.firebaseio.com/';
      default:
        return 'https://your-app-dev-default-rtdb.firebaseio.com/';
    }
  }
  
  // Storage bucket configuration
  static String get storageBucket {
    switch (_environment) {
      case 'development':
        return 'your-app-dev.appspot.com';
      case 'staging':
        return 'your-app-staging.appspot.com';
      case 'production':
        return 'your-app-prod.appspot.com';
      case 'test':
        return 'mock-storage.appspot.com';
      default:
        return 'your-app-dev.appspot.com';
    }
  }
  
  // Google Services configuration
  static String get googleServicesApiKey {
    // In real implementation, use secure key management
    switch (_environment) {
      case 'development':
        return const String.fromEnvironment('GOOGLE_API_KEY_DEV', defaultValue: '');
      case 'staging':
        return const String.fromEnvironment('GOOGLE_API_KEY_STAGING', defaultValue: '');
      case 'production':
        return const String.fromEnvironment('GOOGLE_API_KEY_PROD', defaultValue: '');
      case 'test':
        return 'mock-api-key';
      default:
        return '';
    }
  }
  
  // Apple configuration
  static String get appleTeamId {
    return const String.fromEnvironment('APPLE_TEAM_ID', defaultValue: '');
  }
  
  static String get appleClientId {
    switch (_environment) {
      case 'development':
        return 'com.yourapp.dev.signin';
      case 'staging':
        return 'com.yourapp.staging.signin';
      case 'production':
        return 'com.yourapp.signin';
      case 'test':
        return 'com.yourapp.test.signin';
      default:
        return 'com.yourapp.dev.signin';
    }
  }
  
  // Security configuration
  static bool get enableEncryption => isProduction || isStaging;
  static bool get requireStrongPasswords => isProduction || isStaging;
  static bool get enableBiometrics => !isTest;
  static bool get enableTwoFactorAuth => isProduction;
  
  // Performance configuration
  static int get networkTimeoutSeconds {
    switch (_environment) {
      case 'development':
        return 60; // Longer timeout for debugging
      case 'staging':
        return 45;
      case 'production':
        return 30;
      case 'test':
        return 5; // Quick timeout for tests
      default:
        return 30;
    }
  }
  
  static int get maxRetryAttempts {
    switch (_environment) {
      case 'development':
        return 5;
      case 'staging':
        return 3;
      case 'production':
        return 3;
      case 'test':
        return 1;
      default:
        return 3;
    }
  }
  
  // Logging configuration
  static bool get enableVerboseLogs => isDevelopment || isTest;
  static bool get enableNetworkLogs => isDevelopment;
  static bool get enablePerformanceLogs => isDevelopment || isStaging;
  
  // Cache configuration
  static Duration get cacheExpiry {
    switch (_environment) {
      case 'development':
        return const Duration(minutes: 5); // Short cache for development
      case 'staging':
        return const Duration(hours: 1);
      case 'production':
        return const Duration(hours: 6);
      case 'test':
        return const Duration(seconds: 10);
      default:
        return const Duration(hours: 1);
    }
  }
  
  // Rate limiting configuration
  static int get maxRequestsPerMinute {
    switch (_environment) {
      case 'development':
        return 100; // Higher limit for development
      case 'staging':
        return 60;
      case 'production':
        return 60;
      case 'test':
        return 1000; // No real limit for tests
      default:
        return 60;
    }
  }
  
  /// Print current environment configuration
  static void printConfig() {
    if (enableDebugLogs) {
      debugPrint('=== Environment Configuration ===');
      debugPrint('Environment: $environment');
      debugPrint('App Name: $appName');
      debugPrint('Bundle ID: $bundleId');
      debugPrint('API Base URL: $apiBaseUrl');
      debugPrint('Firebase Project: $firebaseProjectId');
      debugPrint('Enable Firebase: $enableFirebase');
      debugPrint('Enable Analytics: $enableAnalytics');
      debugPrint('Enable Crash Reporting: $enableCrashReporting');
      debugPrint('Enable Debug Logs: $enableDebugLogs');
      debugPrint('Network Timeout: ${networkTimeoutSeconds}s');
      debugPrint('Max Retry Attempts: $maxRetryAttempts');
      debugPrint('Cache Expiry: $cacheExpiry');
      debugPrint('================================');
    }
  }
  
  /// Validate environment configuration
  static bool validateConfig() {
    final issues = <String>[];
    
    if (apiBaseUrl.isEmpty) {
      issues.add('API Base URL is not configured');
    }
    
    if (enableFirebase && firebaseProjectId.isEmpty) {
      issues.add('Firebase Project ID is not configured');
    }
    
    if (isProduction && enableDebugLogs) {
      issues.add('Debug logs should be disabled in production');
    }
    
    if (issues.isNotEmpty) {
      debugPrint('Environment Configuration Issues:');
      for (final issue in issues) {
        debugPrint('- $issue');
      }
      return false;
    }
    
    return true;
  }
}