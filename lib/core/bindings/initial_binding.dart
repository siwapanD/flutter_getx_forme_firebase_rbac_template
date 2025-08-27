import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/providers/auth_provider.dart';
import '../../data/providers/firebase_provider.dart';
import '../../data/providers/storage_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../app/shared/controllers/auth_controller.dart';
import '../../app/shared/controllers/theme_controller.dart';
import '../../app/shared/controllers/connectivity_controller.dart';
import '../config/env.dart';

/// Initial dependency injection binding
/// 
/// This binding is executed when the app starts and sets up all the core
/// dependencies that are needed throughout the application lifecycle.
/// It includes repositories, controllers, and services with test mock fallbacks.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    _initializeStorage();
    _initializeProviders();
    _initializeRepositories();
    _initializeControllers();
    _initializeServices();
  }
  
  /// Initialize storage services
  void _initializeStorage() {
    // Initialize GetStorage for local data persistence
    Get.putAsync<GetStorage>(() async {
      await GetStorage.init();
      return GetStorage();
    }, permanent: true);
    
    // Storage provider for abstracted storage operations
    Get.lazyPut<StorageProvider>(
      () => StorageProvider(),
      fenix: true,
    );
  }
  
  /// Initialize data providers
  void _initializeProviders() {
    // Firebase provider (with test mock fallback)
    Get.lazyPut<FirebaseProvider>(
      () => Env.isTest ? MockFirebaseProvider() : FirebaseProvider(),
      fenix: true,
    );
    
    // Authentication provider
    Get.lazyPut<AuthProvider>(
      () => Env.isTest ? MockAuthProvider() : AuthProvider(),
      fenix: true,
    );
  }
  
  /// Initialize repositories
  void _initializeRepositories() {
    // Authentication repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(),
      fenix: true,
    );
    
    // User repository
    Get.lazyPut<UserRepository>(
      () => UserRepository(),
      fenix: true,
    );
  }
  
  /// Initialize core controllers
  void _initializeControllers() {
    // Authentication controller - permanent for app lifecycle
    Get.put<AuthController>(
      AuthController(),
      permanent: true,
    );
    
    // Theme controller - permanent for app lifecycle
    Get.put<ThemeController>(
      ThemeController(),
      permanent: true,
    );
    
    // Connectivity controller - permanent for app lifecycle
    Get.put<ConnectivityController>(
      ConnectivityController(),
      permanent: true,
    );
  }
  
  /// Initialize additional services
  void _initializeServices() {
    // Add any additional services that need to be initialized
    // For example: notification service, analytics, etc.
  }
}

/// Mock implementations for testing
class MockFirebaseProvider extends FirebaseProvider {
  @override
  Future<void> initialize() async {
    // Mock implementation for testing
  }
  
  @override
  bool get isInitialized => true;
}

class MockAuthProvider extends AuthProvider {
  @override
  Future<Map<String, dynamic>?> signInWithEmail(
    String email, 
    String password,
  ) async {
    // Mock implementation for testing
    return {
      'uid': 'mock_user_id',
      'email': email,
      'displayName': 'Mock User',
      'role': 'user',
    };
  }
  
  @override
  Future<void> signOut() async {
    // Mock implementation for testing
  }
  
  @override
  Stream<Map<String, dynamic>?> get authStateChanges {
    // Mock implementation for testing
    return Stream.value(null);
  }
}