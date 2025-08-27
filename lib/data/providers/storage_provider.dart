import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

import '../../core/utils/result.dart';
import '../../core/constants/app_constants.dart';
import '../../core/config/env.dart';

/// Storage provider that abstracts local storage operations
/// 
/// This provider provides a unified interface for local storage operations
/// using GetStorage for simple key-value storage and SharedPreferences
/// as a fallback. It includes encryption for sensitive data.
class StorageProvider {
  static StorageProvider? _instance;
  static StorageProvider get instance => _instance ??= StorageProvider._();
  
  StorageProvider._();
  
  GetStorage? _getStorage;
  SharedPreferences? _sharedPreferences;
  bool _isInitialized = false;
  
  /// Check if storage is initialized
  bool get isInitialized => _isInitialized;
  
  /// Initialize storage
  Future<VoidResult> initialize() async {
    if (_isInitialized) {
      return VoidResults.success();
    }
    
    try {
      // Initialize GetStorage
      await GetStorage.init();
      _getStorage = GetStorage();
      
      // Initialize SharedPreferences as fallback
      _sharedPreferences = await SharedPreferences.getInstance();
      
      _isInitialized = true;
      
      if (Env.enableDebugLogs) {
        print('Storage initialized successfully');
      }
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      if (Env.enableDebugLogs) {
        print('Storage initialization failed: $e');
      }
      return VoidResults.failure('Storage initialization failed: $e', stackTrace);
    }
  }
  
  /// Store a value with optional encryption
  Future<VoidResult> store(
    String key,
    dynamic value, {
    bool encrypt = false,
  }) async {
    if (!_isInitialized) {
      return VoidResults.failure('Storage not initialized');
    }
    
    try {
      final processedValue = encrypt && Env.enableEncryption
          ? _encryptValue(value)
          : value;
      
      // Try GetStorage first
      if (_getStorage != null) {
        await _getStorage!.write(key, processedValue);
        return VoidResults.success();
      }
      
      // Fallback to SharedPreferences
      if (_sharedPreferences != null) {
        await _storeInSharedPreferences(key, processedValue);
        return VoidResults.success();
      }
      
      return VoidResults.failure('No storage available');
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to store data: $e', stackTrace);
    }
  }
  
  /// Retrieve a value with optional decryption
  Future<Result<T?>> retrieve<T>(
    String key, {
    bool decrypt = false,
    T? defaultValue,
  }) async {
    if (!_isInitialized) {
      return const Result.failure('Storage not initialized');
    }
    
    try {
      dynamic value;
      
      // Try GetStorage first
      if (_getStorage != null) {
        value = _getStorage!.read(key);
      } else if (_sharedPreferences != null) {
        value = _retrieveFromSharedPreferences(key);
      }
      
      if (value == null) {
        return Result.success(defaultValue);
      }
      
      final processedValue = decrypt && Env.enableEncryption
          ? _decryptValue(value)
          : value;
      
      // Type checking and conversion
      if (processedValue is T) {
        return Result.success(processedValue);
      } else if (T == String && processedValue != null) {
        return Result.success(processedValue.toString() as T);
      } else if (T == int && processedValue is String) {
        final intValue = int.tryParse(processedValue);
        return Result.success(intValue as T?);
      } else if (T == double && processedValue is String) {
        final doubleValue = double.tryParse(processedValue);
        return Result.success(doubleValue as T?);
      } else if (T == bool && processedValue is String) {
        final boolValue = processedValue.toLowerCase() == 'true';
        return Result.success(boolValue as T);
      } else {
        return Result.success(defaultValue);
      }
    } catch (e, stackTrace) {
      return Result.failure('Failed to retrieve data: $e', stackTrace);
    }
  }
  
  /// Remove a key from storage
  Future<VoidResult> remove(String key) async {
    if (!_isInitialized) {
      return VoidResults.failure('Storage not initialized');
    }
    
    try {
      if (_getStorage != null) {
        await _getStorage!.remove(key);
      }
      
      if (_sharedPreferences != null) {
        await _sharedPreferences!.remove(key);
      }
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to remove data: $e', stackTrace);
    }
  }
  
  /// Check if a key exists
  Future<Result<bool>> hasKey(String key) async {
    if (!_isInitialized) {
      return const Result.failure('Storage not initialized');
    }
    
    try {
      bool exists = false;
      
      if (_getStorage != null) {
        exists = _getStorage!.hasData(key);
      } else if (_sharedPreferences != null) {
        exists = _sharedPreferences!.containsKey(key);
      }
      
      return Result.success(exists);
    } catch (e, stackTrace) {
      return Result.failure('Failed to check key existence: $e', stackTrace);
    }
  }
  
  /// Get all keys
  Future<Result<List<String>>> getAllKeys() async {
    if (!_isInitialized) {
      return const Result.failure('Storage not initialized');
    }
    
    try {
      List<String> keys = [];
      
      if (_getStorage != null) {
        keys = _getStorage!.getKeys().whereType<String>().toList();
      } else if (_sharedPreferences != null) {
        keys = _sharedPreferences!.getKeys().toList();
      }
      
      return Result.success(keys);
    } catch (e, stackTrace) {
      return Result.failure('Failed to get keys: $e', stackTrace);
    }
  }
  
  /// Clear all data
  Future<VoidResult> clear() async {
    if (!_isInitialized) {
      return VoidResults.failure('Storage not initialized');
    }
    
    try {
      if (_getStorage != null) {
        await _getStorage!.erase();
      }
      
      if (_sharedPreferences != null) {
        await _sharedPreferences!.clear();
      }
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to clear storage: $e', stackTrace);
    }
  }
  
  /// Store JSON data
  Future<VoidResult> storeJson(
    String key,
    Map<String, dynamic> data, {
    bool encrypt = false,
  }) async {
    try {
      final jsonString = jsonEncode(data);
      return await store(key, jsonString, encrypt: encrypt);
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to store JSON: $e', stackTrace);
    }
  }
  
  /// Retrieve JSON data
  Future<Result<Map<String, dynamic>?>> retrieveJson(
    String key, {
    bool decrypt = false,
  }) async {
    try {
      final result = await retrieve<String>(key, decrypt: decrypt);
      
      return result.map((jsonString) {
        if (jsonString == null) return null;
        return jsonDecode(jsonString) as Map<String, dynamic>;
      });
    } catch (e, stackTrace) {
      return Result.failure('Failed to retrieve JSON: $e', stackTrace);
    }
  }
  
  /// Store a list
  Future<VoidResult> storeList(
    String key,
    List<dynamic> list, {
    bool encrypt = false,
  }) async {
    try {
      final jsonString = jsonEncode(list);
      return await store(key, jsonString, encrypt: encrypt);
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to store list: $e', stackTrace);
    }
  }
  
  /// Retrieve a list
  Future<Result<List<dynamic>?>> retrieveList(
    String key, {
    bool decrypt = false,
  }) async {
    try {
      final result = await retrieve<String>(key, decrypt: decrypt);
      
      return result.map((jsonString) {
        if (jsonString == null) return null;
        return jsonDecode(jsonString) as List<dynamic>;
      });
    } catch (e, stackTrace) {
      return Result.failure('Failed to retrieve list: $e', stackTrace);
    }
  }
  
  /// Store user data with encryption
  Future<VoidResult> storeUserData(Map<String, dynamic> userData) async {
    return await storeJson(
      AppConstants.storageKeyUser,
      userData,
      encrypt: true,
    );
  }
  
  /// Retrieve user data with decryption
  Future<Result<Map<String, dynamic>?>> retrieveUserData() async {
    return await retrieveJson(
      AppConstants.storageKeyUser,
      decrypt: true,
    );
  }
  
  /// Store authentication token with encryption
  Future<VoidResult> storeToken(String token) async {
    return await store(
      AppConstants.storageKeyToken,
      token,
      encrypt: true,
    );
  }
  
  /// Retrieve authentication token with decryption
  Future<Result<String?>> retrieveToken() async {
    return await retrieve<String>(
      AppConstants.storageKeyToken,
      decrypt: true,
    );
  }
  
  /// Store refresh token with encryption
  Future<VoidResult> storeRefreshToken(String refreshToken) async {
    return await store(
      AppConstants.storageKeyRefreshToken,
      refreshToken,
      encrypt: true,
    );
  }
  
  /// Retrieve refresh token with decryption
  Future<Result<String?>> retrieveRefreshToken() async {
    return await retrieve<String>(
      AppConstants.storageKeyRefreshToken,
      decrypt: true,
    );
  }
  
  /// Clear all authentication data
  Future<VoidResult> clearAuthData() async {
    final results = await Future.wait([
      remove(AppConstants.storageKeyToken),
      remove(AppConstants.storageKeyRefreshToken),
      remove(AppConstants.storageKeyUser),
      remove(AppConstants.storageKeyPermissions),
    ]);
    
    // Check if any operation failed
    for (final result in results) {
      if (result.isFailure) {
        return result;
      }
    }
    
    return VoidResults.success();
  }
  
  /// Store in SharedPreferences (fallback)
  Future<void> _storeInSharedPreferences(String key, dynamic value) async {
    if (value is String) {
      await _sharedPreferences!.setString(key, value);
    } else if (value is int) {
      await _sharedPreferences!.setInt(key, value);
    } else if (value is double) {
      await _sharedPreferences!.setDouble(key, value);
    } else if (value is bool) {
      await _sharedPreferences!.setBool(key, value);
    } else if (value is List<String>) {
      await _sharedPreferences!.setStringList(key, value);
    } else {
      // Convert to JSON string for complex objects
      final jsonString = jsonEncode(value);
      await _sharedPreferences!.setString(key, jsonString);
    }
  }
  
  /// Retrieve from SharedPreferences (fallback)
  dynamic _retrieveFromSharedPreferences(String key) {
    return _sharedPreferences!.get(key);
  }
  
  /// Encrypt value using simple encryption (for demo purposes)
  /// In production, use more robust encryption
  String _encryptValue(dynamic value) {
    final jsonString = jsonEncode(value);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    
    // Simple encryption - in production, use proper encryption
    final encrypted = base64Encode(bytes);
    return encrypted;
  }
  
  /// Decrypt value using simple decryption (for demo purposes)
  /// In production, use proper decryption
  dynamic _decryptValue(String encryptedValue) {
    try {
      final decoded = base64Decode(encryptedValue);
      final jsonString = utf8.decode(decoded);
      return jsonDecode(jsonString);
    } catch (e) {
      // If decryption fails, return the original value
      return encryptedValue;
    }
  }
  
  /// Get storage size (approximate)
  Future<Result<int>> getStorageSize() async {
    if (!_isInitialized) {
      return const Result.failure('Storage not initialized');
    }
    
    try {
      int totalSize = 0;
      
      if (_getStorage != null) {
        final keys = _getStorage!.getKeys();
        for (final key in keys) {
          final value = _getStorage!.read(key);
          if (value != null) {
            final jsonString = jsonEncode(value);
            totalSize += utf8.encode(jsonString).length;
          }
        }
      }
      
      return Result.success(totalSize);
    } catch (e, stackTrace) {
      return Result.failure('Failed to calculate storage size: $e', stackTrace);
    }
  }
  
  /// Export data for backup
  Future<Result<Map<String, dynamic>>> exportData() async {
    if (!_isInitialized) {
      return const Result.failure('Storage not initialized');
    }
    
    try {
      final exportData = <String, dynamic>{};
      
      if (_getStorage != null) {
        final keys = _getStorage!.getKeys().whereType<String>();
        for (final key in keys) {
          // Skip sensitive data in export
          if (!_isSensitiveKey(key)) {
            exportData[key] = _getStorage!.read(key);
          }
        }
      }
      
      return Result.success(exportData);
    } catch (e, stackTrace) {
      return Result.failure('Failed to export data: $e', stackTrace);
    }
  }
  
  /// Check if a key contains sensitive data
  bool _isSensitiveKey(String key) {
    const sensitiveKeys = [
      AppConstants.storageKeyToken,
      AppConstants.storageKeyRefreshToken,
      AppConstants.storageKeyUser,
    ];
    
    return sensitiveKeys.contains(key);
  }
}