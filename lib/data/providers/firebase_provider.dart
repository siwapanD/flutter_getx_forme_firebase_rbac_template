import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/config/env.dart';
import '../../core/utils/result.dart';

/// Firebase provider that handles Firebase initialization and configuration
/// 
/// This provider manages Firebase services initialization and provides
/// access to Firebase services with proper error handling.
class FirebaseProvider {
  static FirebaseProvider? _instance;
  static FirebaseProvider get instance => _instance ??= FirebaseProvider._();
  
  FirebaseProvider._();
  
  FirebaseApp? _app;
  FirebaseFirestore? _firestore;
  bool _isInitialized = false;
  
  /// Check if Firebase is initialized
  bool get isInitialized => _isInitialized;
  
  /// Get Firebase app instance
  FirebaseApp? get app => _app;
  
  /// Get Firestore instance
  FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw StateError('Firebase not initialized. Call initialize() first.');
    }
    return _firestore!;
  }
  
  /// Initialize Firebase with environment-specific configuration
  Future<VoidResult> initialize() async {
    if (_isInitialized) {
      return VoidResults.success();
    }
    
    try {
      // Initialize Firebase with environment-specific options
      _app = await Firebase.initializeApp(
        options: _getFirebaseOptions(),
      );
      
      // Initialize Firestore with settings
      _firestore = FirebaseFirestore.instanceFor(app: _app!);
      await _configureFirestore();
      
      _isInitialized = true;
      
      if (Env.enableDebugLogs) {
        print('Firebase initialized successfully for ${Env.environment}');
      }
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      if (Env.enableDebugLogs) {
        print('Firebase initialization failed: $e');
      }
      return VoidResults.failure('Firebase initialization failed: $e', stackTrace);
    }
  }
  
  /// Configure Firestore settings
  Future<void> _configureFirestore() async {
    final settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    
    _firestore!.settings = settings;
    
    // Enable offline persistence for better user experience
    try {
      await _firestore!.enablePersistence();
    } catch (e) {
      // Persistence might already be enabled or not supported
      if (Env.enableDebugLogs) {
        print('Firestore persistence setup: $e');
      }
    }
  }
  
  /// Get Firebase options based on environment
  FirebaseOptions _getFirebaseOptions() {
    switch (Env.environment) {
      case 'development':
        return _getDevelopmentOptions();
      case 'staging':
        return _getStagingOptions();
      case 'production':
        return _getProductionOptions();
      case 'test':
        return _getTestOptions();
      default:
        return _getDevelopmentOptions();
    }
  }
  
  /// Development Firebase options
  FirebaseOptions _getDevelopmentOptions() {
    return const FirebaseOptions(
      apiKey: 'your-dev-api-key',
      appId: 'your-dev-app-id',
      messagingSenderId: 'your-dev-sender-id',
      projectId: 'your-app-dev',
      authDomain: 'your-app-dev.firebaseapp.com',
      storageBucket: 'your-app-dev.appspot.com',
      databaseURL: 'https://your-app-dev-default-rtdb.firebaseio.com',
    );
  }
  
  /// Staging Firebase options
  FirebaseOptions _getStagingOptions() {
    return const FirebaseOptions(
      apiKey: 'your-staging-api-key',
      appId: 'your-staging-app-id',
      messagingSenderId: 'your-staging-sender-id',
      projectId: 'your-app-staging',
      authDomain: 'your-app-staging.firebaseapp.com',
      storageBucket: 'your-app-staging.appspot.com',
      databaseURL: 'https://your-app-staging-default-rtdb.firebaseio.com',
    );
  }
  
  /// Production Firebase options
  FirebaseOptions _getProductionOptions() {
    return const FirebaseOptions(
      apiKey: 'your-prod-api-key',
      appId: 'your-prod-app-id',
      messagingSenderId: 'your-prod-sender-id',
      projectId: 'your-app-prod',
      authDomain: 'your-app-prod.firebaseapp.com',
      storageBucket: 'your-app-prod.appspot.com',
      databaseURL: 'https://your-app-prod-default-rtdb.firebaseio.com',
    );
  }
  
  /// Test Firebase options (mock/emulator)
  FirebaseOptions _getTestOptions() {
    return const FirebaseOptions(
      apiKey: 'test-api-key',
      appId: 'test-app-id',
      messagingSenderId: 'test-sender-id',
      projectId: 'test-project',
      authDomain: 'test-project.firebaseapp.com',
      storageBucket: 'test-project.appspot.com',
      databaseURL: 'https://test-project-default-rtdb.firebaseio.com',
    );
  }
  
  /// Batch write operation with error handling
  Future<VoidResult> batchWrite(
    List<BatchOperation> operations,
  ) async {
    if (!_isInitialized) {
      return VoidResults.failure('Firebase not initialized');
    }
    
    try {
      final batch = _firestore!.batch();
      
      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.set:
            batch.set(operation.reference, operation.data!);
            break;
          case BatchOperationType.update:
            batch.update(operation.reference, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(operation.reference);
            break;
        }
      }
      
      await batch.commit();
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Batch write failed: $e', stackTrace);
    }
  }
  
  /// Transaction operation with error handling
  Future<Result<T>> runTransaction<T>(
    Future<T> Function(Transaction) operation,
  ) async {
    if (!_isInitialized) {
      return const Result.failure('Firebase not initialized');
    }
    
    try {
      final result = await _firestore!.runTransaction(operation);
      return Result.success(result);
    } catch (e, stackTrace) {
      return Result.failure('Transaction failed: $e', stackTrace);
    }
  }
  
  /// Get collection reference with type safety
  CollectionReference<Map<String, dynamic>> collection(String path) {
    if (!_isInitialized) {
      throw StateError('Firebase not initialized');
    }
    return _firestore!.collection(path);
  }
  
  /// Get document reference with type safety
  DocumentReference<Map<String, dynamic>> document(String path) {
    if (!_isInitialized) {
      throw StateError('Firebase not initialized');
    }
    return _firestore!.doc(path);
  }
  
  /// Check connection status
  Future<bool> isConnected() async {
    if (!_isInitialized) return false;
    
    try {
      // Try to perform a simple read operation with timeout
      final doc = await _firestore!
          .collection('_connection_test')
          .doc('test')
          .get()
          .timeout(const Duration(seconds: 5));
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Enable/disable network
  Future<VoidResult> setNetworkEnabled(bool enabled) async {
    if (!_isInitialized) {
      return VoidResults.failure('Firebase not initialized');
    }
    
    try {
      if (enabled) {
        await _firestore!.enableNetwork();
      } else {
        await _firestore!.disableNetwork();
      }
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure(
        'Failed to ${enabled ? 'enable' : 'disable'} network: $e',
        stackTrace,
      );
    }
  }
  
  /// Clear local cache
  Future<VoidResult> clearCache() async {
    if (!_isInitialized) {
      return VoidResults.failure('Firebase not initialized');
    }
    
    try {
      await _firestore!.clearPersistence();
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to clear cache: $e', stackTrace);
    }
  }
  
  /// Dispose Firebase resources
  Future<VoidResult> dispose() async {
    try {
      if (_isInitialized && _app != null) {
        await _app!.delete();
        _app = null;
        _firestore = null;
        _isInitialized = false;
      }
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to dispose Firebase: $e', stackTrace);
    }
  }
}

/// Batch operation types
enum BatchOperationType { set, update, delete }

/// Batch operation model
class BatchOperation {
  final BatchOperationType type;
  final DocumentReference reference;
  final Map<String, dynamic>? data;
  
  const BatchOperation({
    required this.type,
    required this.reference,
    this.data,
  });
  
  /// Create a set operation
  factory BatchOperation.set(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) =>
      BatchOperation(
        type: BatchOperationType.set,
        reference: reference,
        data: data,
      );
  
  /// Create an update operation
  factory BatchOperation.update(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) =>
      BatchOperation(
        type: BatchOperationType.update,
        reference: reference,
        data: data,
      );
  
  /// Create a delete operation
  factory BatchOperation.delete(DocumentReference reference) => BatchOperation(
        type: BatchOperationType.delete,
        reference: reference,
      );
}