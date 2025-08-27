import 'package:get/get.dart';

import '../providers/auth_provider.dart';
import '../providers/storage_provider.dart';
import '../models/user_model.dart';
import '../../core/utils/result.dart';
import '../../core/constants/app_constants.dart';

/// Authentication repository that handles auth operations and local storage
/// 
/// This repository coordinates between the AuthProvider for Firebase operations
/// and StorageProvider for local data persistence, providing a unified
/// authentication interface for the application.
class AuthRepository {
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  final StorageProvider _storageProvider = Get.find<StorageProvider>();
  
  /// Sign in with email and password
  Future<Result<UserModel>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        return const Result.failure('Email and password are required');
      }
      
      if (!_isValidEmail(email)) {
        return const Result.failure('Invalid email format');
      }
      
      // Attempt sign in
      final result = await _authProvider.signInWithEmail(email, password);
      
      if (result.isSuccess) {
        // Store user data locally
        await _storageProvider.storeUserData(result.value.toJson());
        
        // Update last sign in
        final updatedUser = result.value.updateLastSignIn();
        await _storageProvider.storeUserData(updatedUser.toJson());
        
        return Result.success(updatedUser);
      }
      
      return Result.failure(result.errorOrNull!);
    } catch (e, stackTrace) {
      return Result.failure('Sign in failed: $e', stackTrace);
    }
  }
  
  /// Sign up with email and password
  Future<Result<UserModel>> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
        return const Result.failure('All fields are required');
      }
      
      if (!_isValidEmail(email)) {
        return const Result.failure('Invalid email format');
      }
      
      if (password.length < AppConstants.minPasswordLength) {
        return Result.failure(
          'Password must be at least ${AppConstants.minPasswordLength} characters',
        );
      }
      
      if (displayName.length < AppConstants.minUsernameLength) {
        return Result.failure(
          'Display name must be at least ${AppConstants.minUsernameLength} characters',
        );
      }
      
      // Attempt sign up
      final result = await _authProvider.signUpWithEmail(
        email,
        password,
        displayName,
      );
      
      if (result.isSuccess) {
        // Store user data locally
        await _storageProvider.storeUserData(result.value.toJson());
        
        return result;
      }
      
      return Result.failure(result.errorOrNull!);
    } catch (e, stackTrace) {
      return Result.failure('Sign up failed: $e', stackTrace);
    }
  }
  
  /// Sign in with Google
  Future<Result<UserModel>> signInWithGoogle() async {
    try {
      final result = await _authProvider.signInWithGoogle();
      
      if (result.isSuccess) {
        // Store user data locally
        await _storageProvider.storeUserData(result.value.toJson());
        
        // Update last sign in
        final updatedUser = result.value.updateLastSignIn();
        await _storageProvider.storeUserData(updatedUser.toJson());
        
        return Result.success(updatedUser);
      }
      
      return Result.failure(result.errorOrNull!);
    } catch (e, stackTrace) {
      return Result.failure('Google sign in failed: $e', stackTrace);
    }
  }
  
  /// Sign in with Apple
  Future<Result<UserModel>> signInWithApple() async {
    try {
      final result = await _authProvider.signInWithApple();
      
      if (result.isSuccess) {
        // Store user data locally
        await _storageProvider.storeUserData(result.value.toJson());
        
        // Update last sign in
        final updatedUser = result.value.updateLastSignIn();
        await _storageProvider.storeUserData(updatedUser.toJson());
        
        return Result.success(updatedUser);
      }
      
      return Result.failure(result.errorOrNull!);
    } catch (e, stackTrace) {
      return Result.failure('Apple sign in failed: $e', stackTrace);
    }
  }
  
  /// Send password reset email
  Future<VoidResult> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) {
        return VoidResults.failure('Email is required');
      }
      
      if (!_isValidEmail(email)) {
        return VoidResults.failure('Invalid email format');
      }
      
      return await _authProvider.sendPasswordResetEmail(email);
    } catch (e, stackTrace) {
      return VoidResults.failure('Password reset failed: $e', stackTrace);
    }
  }
  
  /// Send email verification
  Future<VoidResult> sendEmailVerification() async {
    try {
      return await _authProvider.sendEmailVerification();
    } catch (e, stackTrace) {
      return VoidResults.failure('Email verification failed: $e', stackTrace);
    }
  }
  
  /// Update user profile
  Future<Result<UserModel>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final result = await _authProvider.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      
      if (result.isSuccess) {
        // Update local storage
        await _storageProvider.storeUserData(result.value.toJson());
        return result;
      }
      
      return Result.failure(result.errorOrNull!);
    } catch (e, stackTrace) {
      return Result.failure('Profile update failed: $e', stackTrace);
    }
  }
  
  /// Change password
  Future<VoidResult> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        return VoidResults.failure('Both passwords are required');
      }
      
      if (newPassword.length < AppConstants.minPasswordLength) {
        return VoidResults.failure(
          'New password must be at least ${AppConstants.minPasswordLength} characters',
        );
      }
      
      if (currentPassword == newPassword) {
        return VoidResults.failure('New password must be different from current password');
      }
      
      return await _authProvider.changePassword(currentPassword, newPassword);
    } catch (e, stackTrace) {
      return VoidResults.failure('Password change failed: $e', stackTrace);
    }
  }
  
  /// Delete user account
  Future<VoidResult> deleteAccount(String password) async {
    try {
      if (password.isEmpty) {
        return VoidResults.failure('Password is required');
      }
      
      final result = await _authProvider.deleteAccount(password);
      
      if (result.isSuccess) {
        // Clear all local data
        await _storageProvider.clearAuthData();
      }
      
      return result;
    } catch (e, stackTrace) {
      return VoidResults.failure('Account deletion failed: $e', stackTrace);
    }
  }
  
  /// Sign out
  Future<VoidResult> signOut() async {
    try {
      final result = await _authProvider.signOut();
      
      // Clear local storage regardless of Firebase result
      await _storageProvider.clearAuthData();
      
      return result;
    } catch (e, stackTrace) {
      // Even if Firebase sign out fails, clear local data
      await _storageProvider.clearAuthData();
      return VoidResults.failure('Sign out failed: $e', stackTrace);
    }
  }
  
  /// Get current user from local storage
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      final userData = await _storageProvider.retrieveUserData();
      
      if (userData.isSuccess && userData.value != null) {
        final user = UserModel.fromJson(userData.value!);
        return Result.success(user);
      }
      
      // Try to get from Firebase if not in local storage
      final firebaseResult = await _authProvider.getCurrentUser();
      
      if (firebaseResult.isSuccess) {
        // Store in local storage for future access
        await _storageProvider.storeUserData(firebaseResult.value.toJson());
        return firebaseResult;
      }
      
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure('Failed to get current user: $e', stackTrace);
    }
  }
  
  /// Check if user is authenticated (has valid session)
  Future<Result<bool>> isAuthenticated() async {
    try {
      final userResult = await getCurrentUser();
      
      if (userResult.isSuccess && userResult.value != null) {
        final user = userResult.value!;
        
        // Check if user is active and not blocked
        if (!user.isActive || user.isBlocked) {
          return const Result.success(false);
        }
        
        // Check if token exists and is valid
        final tokenResult = await _storageProvider.retrieveToken();
        
        if (tokenResult.isSuccess && tokenResult.value != null) {
          // TODO: Validate token expiry
          return const Result.success(true);
        }
      }
      
      return const Result.success(false);
    } catch (e, stackTrace) {
      return Result.failure('Authentication check failed: $e', stackTrace);
    }
  }
  
  /// Refresh user data from Firebase
  Future<Result<UserModel>> refreshUser() async {
    try {
      final result = await _authProvider.getCurrentUser();
      
      if (result.isSuccess) {
        // Update local storage
        await _storageProvider.storeUserData(result.value.toJson());
        return result;
      }
      
      return Result.failure(result.errorOrNull!);
    } catch (e, stackTrace) {
      return Result.failure('User refresh failed: $e', stackTrace);
    }
  }
  
  /// Check if user has specific permission
  Future<Result<bool>> hasPermission(String permission) async {
    try {
      final userResult = await getCurrentUser();
      
      if (userResult.isSuccess && userResult.value != null) {
        return Result.success(userResult.value!.hasPermission(permission));
      }
      
      return const Result.success(false);
    } catch (e, stackTrace) {
      return Result.failure('Permission check failed: $e', stackTrace);
    }
  }
  
  /// Check if user has specific role
  Future<Result<bool>> hasRole(String role) async {
    try {
      final userResult = await getCurrentUser();
      
      if (userResult.isSuccess && userResult.value != null) {
        return Result.success(userResult.value!.hasRole(role));
      }
      
      return const Result.success(false);
    } catch (e, stackTrace) {
      return Result.failure('Role check failed: $e', stackTrace);
    }
  }
  
  /// Check if user has any of the specified roles
  Future<Result<bool>> hasAnyRole(List<String> roles) async {
    try {
      final userResult = await getCurrentUser();
      
      if (userResult.isSuccess && userResult.value != null) {
        return Result.success(userResult.value!.hasAnyRole(roles));
      }
      
      return const Result.success(false);
    } catch (e, stackTrace) {
      return Result.failure('Role check failed: $e', stackTrace);
    }
  }
  
  /// Update user's last activity timestamp
  Future<VoidResult> updateLastActivity() async {
    try {
      final userResult = await getCurrentUser();
      
      if (userResult.isSuccess && userResult.value != null) {
        final updatedUser = userResult.value!.copyWith(
          updatedAt: DateTime.now(),
        );
        
        await _storageProvider.storeUserData(updatedUser.toJson());
        return VoidResults.success();
      }
      
      return VoidResults.failure('No user found');
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to update last activity: $e', stackTrace);
    }
  }
  
  /// Store authentication token
  Future<VoidResult> storeToken(String token) async {
    try {
      return await _storageProvider.storeToken(token);
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to store token: $e', stackTrace);
    }
  }
  
  /// Store refresh token
  Future<VoidResult> storeRefreshToken(String refreshToken) async {
    try {
      return await _storageProvider.storeRefreshToken(refreshToken);
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to store refresh token: $e', stackTrace);
    }
  }
  
  /// Get stored token
  Future<Result<String?>> getToken() async {
    try {
      return await _storageProvider.retrieveToken();
    } catch (e, stackTrace) {
      return Result.failure('Failed to retrieve token: $e', stackTrace);
    }
  }
  
  /// Get stored refresh token
  Future<Result<String?>> getRefreshToken() async {
    try {
      return await _storageProvider.retrieveRefreshToken();
    } catch (e, stackTrace) {
      return Result.failure('Failed to retrieve refresh token: $e', stackTrace);
    }
  }
  
  /// Clear all authentication data
  Future<VoidResult> clearAuthData() async {
    try {
      return await _storageProvider.clearAuthData();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to clear auth data: $e', stackTrace);
    }
  }
  
  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
  
  /// Validate password strength
  bool _isValidPassword(String password) {
    if (password.length < AppConstants.minPasswordLength) {
      return false;
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return false;
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return false;
    }
    
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return false;
    }
    
    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return false;
    }
    
    return true;
  }
  
  /// Get password validation errors
  List<String> getPasswordValidationErrors(String password) {
    final errors = <String>[];
    
    if (password.length < AppConstants.minPasswordLength) {
      errors.add('Password must be at least ${AppConstants.minPasswordLength} characters');
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('Password must contain at least one uppercase letter');
    }
    
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('Password must contain at least one lowercase letter');
    }
    
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('Password must contain at least one number');
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add('Password must contain at least one special character');
    }
    
    return errors;
  }
}