import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/providers/auth_provider.dart';
import '../../data/providers/firebase_provider.dart';
import '../../data/providers/storage_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_model.dart';
import '../../app/shared/controllers/auth_controller.dart';
import '../../app/shared/controllers/theme_controller.dart';
import '../../app/shared/controllers/connectivity_controller.dart';
import '../utils/result.dart';
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
      () => StorageProvider.instance,
      fenix: true,
    );
  }
  
  /// Initialize data providers
  void _initializeProviders() {
    // Firebase provider (with test mock fallback)
    Get.lazyPut<FirebaseProvider>(
      () => Env.isTest ? MockFirebaseProvider() : FirebaseProvider.instance,
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
class MockFirebaseProvider implements FirebaseProvider {
  @override
  Future<VoidResult> initialize() async {
    // Mock implementation for testing
    return VoidResults.success();
  }
  
  @override
  bool get isInitialized => true;
  
  @override
  FirebaseApp? get app => null;
  
  @override
  FirebaseFirestore get firestore => throw UnimplementedError('Mock firestore');
  
  @override
  Future<VoidResult> batchWrite(List<BatchOperation> operations) async {
    return VoidResults.success();
  }
  
  @override
  Future<Result<T>> runTransaction<T>(Future<T> Function(Transaction) operation) async {
    throw UnimplementedError('Mock transaction');
  }
  
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    throw UnimplementedError('Mock collection');
  }
  
  @override
  DocumentReference<Map<String, dynamic>> document(String path) {
    throw UnimplementedError('Mock document');
  }
  
  @override
  Future<bool> isConnected() async => true;
  
  @override
  Future<VoidResult> setNetworkEnabled(bool enabled) async {
    return VoidResults.success();
  }
  
  @override
  Future<VoidResult> clearCache() async {
    return VoidResults.success();
  }
  
  @override
  Future<VoidResult> dispose() async {
    return VoidResults.success();
  }
}

class MockAuthProvider extends AuthProvider {
  @override
  Future<Result<UserModel>> signInWithEmail(
    String email, 
    String password,
  ) async {
    // Mock implementation for testing
    final mockUser = UserModel(
      uid: 'mock_user_id',
      email: email,
      displayName: 'Mock User',
      role: 'user',
      permissions: [],
      isActive: true,
      isBlocked: false,
      emailVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return Result.success(mockUser);
  }
  
  @override
  Future<VoidResult> signOut() async {
    // Mock implementation for testing
    return VoidResults.success();
  }
  
  @override
  Stream<User?> get authStateChanges {
    // Mock implementation for testing
    return Stream.value(null);
  }
}