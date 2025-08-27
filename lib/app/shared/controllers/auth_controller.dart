import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/result.dart';

/// Authentication controller managing user authentication state
/// 
/// This controller handles all authentication operations including login, logout,
/// registration, and user state management. It provides reactive state updates
/// and integrates with the RBAC system.
class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  
  // Reactive state
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isAuthenticated = false.obs;
  final RxString _errorMessage = ''.obs;
  
  // Getters
  UserModel? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  String get errorMessage => _errorMessage.value;
  
  // User properties getters
  String get userName => currentUser?.displayName ?? '';
  String get userEmail => currentUser?.email ?? '';
  String get userRole => currentUser?.role ?? AppConstants.roleGuest;
  List<String> get userPermissions => currentUser?.permissions ?? [];
  bool get isEmailVerified => currentUser?.emailVerified ?? false;
  
  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }
  
  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    _setLoading(true);
    
    try {
      // Check if user is already authenticated
      final isAuthResult = await _authRepository.isAuthenticated();
      
      if (isAuthResult.isSuccess && isAuthResult.value) {
        // Load current user
        final userResult = await _authRepository.getCurrentUser();
        
        if (userResult.isSuccess && userResult.value != null) {
          _setCurrentUser(userResult.value!);
          _setAuthenticated(true);
        } else {
          _setAuthenticated(false);
        }
      } else {
        _setAuthenticated(false);
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _setAuthenticated(false);
    }
    
    _setLoading(false);
  }
  
  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authRepository.signInWithEmail(email, password);
      
      if (result.isSuccess) {
        _setCurrentUser(result.value);
        _setAuthenticated(true);
        
        // Navigate to appropriate screen based on role
        _navigateToHomeScreen();
        
        Get.snackbar(
          'Success',
          AppConstants.successLogin,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return true;
      } else {
        _setError(result.errorOrNull?.toString() ?? AppConstants.errorGeneric);
        
        Get.snackbar(
          'Sign In Failed',
          errorMessage,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return false;
      }
    } catch (e) {
      _setError('Sign in failed: $e');
      
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Sign up with email and password
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authRepository.signUpWithEmail(
        email,
        password,
        displayName,
      );
      
      if (result.isSuccess) {
        _setCurrentUser(result.value);
        _setAuthenticated(true);
        
        Get.snackbar(
          'Success',
          AppConstants.successRegister,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        // Navigate to email verification screen if needed
        if (!result.value.emailVerified) {
          Get.toNamed(AppRoutes.verifyEmail);
        } else {
          _navigateToHomeScreen();
        }
        
        return true;
      } else {
        _setError(result.errorOrNull?.toString() ?? AppConstants.errorGeneric);
        
        Get.snackbar(
          'Sign Up Failed',
          errorMessage,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return false;
      }
    } catch (e) {
      _setError('Sign up failed: $e');
      
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authRepository.signInWithGoogle();
      
      if (result.isSuccess) {
        _setCurrentUser(result.value);
        _setAuthenticated(true);
        
        _navigateToHomeScreen();
        
        Get.snackbar(
          'Success',
          'Successfully signed in with Google!',
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return true;
      } else {
        _setError(result.errorOrNull?.toString() ?? AppConstants.errorGeneric);
        
        Get.snackbar(
          'Google Sign In Failed',
          errorMessage,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return false;
      }
    } catch (e) {
      _setError('Google sign in failed: $e');
      
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authRepository.signInWithApple();
      
      if (result.isSuccess) {
        _setCurrentUser(result.value);
        _setAuthenticated(true);
        
        _navigateToHomeScreen();
        
        Get.snackbar(
          'Success',
          'Successfully signed in with Apple!',
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return true;
      } else {
        _setError(result.errorOrNull?.toString() ?? AppConstants.errorGeneric);
        
        Get.snackbar(
          'Apple Sign In Failed',
          errorMessage,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return false;
      }
    } catch (e) {
      _setError('Apple sign in failed: $e');
      
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authRepository.sendPasswordResetEmail(email);
      
      if (result.isSuccess) {
        Get.snackbar(
          'Success',
          'Password reset email sent successfully!',
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return true;
      } else {
        _setError(result.errorOrNull?.toString() ?? AppConstants.errorGeneric);
        
        Get.snackbar(
          'Password Reset Failed',
          errorMessage,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return false;
      }
    } catch (e) {
      _setError('Password reset failed: $e');
      
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Send email verification
  Future<bool> sendEmailVerification() async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authRepository.sendEmailVerification();
      
      if (result.isSuccess) {
        Get.snackbar(
          'Success',
          'Verification email sent successfully!',
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return true;
      } else {
        _setError(result.errorOrNull?.toString() ?? AppConstants.errorGeneric);
        
        Get.snackbar(
          'Email Verification Failed',
          errorMessage,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return false;
      }
    } catch (e) {
      _setError('Email verification failed: $e');
      
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _authRepository.signOut();
      
      _setCurrentUser(null);
      _setAuthenticated(false);
      _clearError();
      
      Get.offAllNamed(AppRoutes.login);
      
      Get.snackbar(
        'Success',
        AppConstants.successLogout,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint('Sign out error: $e');
      
      // Force logout even if Firebase fails
      _setCurrentUser(null);
      _setAuthenticated(false);
      Get.offAllNamed(AppRoutes.login);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Refresh user data
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;
    
    try {
      final result = await _authRepository.refreshUser();
      
      if (result.isSuccess) {
        _setCurrentUser(result.value);
      }
    } catch (e) {
      debugPrint('User refresh error: $e');
    }
  }
  
  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authRepository.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      
      if (result.isSuccess) {
        _setCurrentUser(result.value);
        
        Get.snackbar(
          'Success',
          AppConstants.successUpdate,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return true;
      } else {
        _setError(result.errorOrNull?.toString() ?? AppConstants.errorGeneric);
        
        Get.snackbar(
          'Profile Update Failed',
          errorMessage,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: $e');
      
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Check if user has permission
  bool hasPermission(String permission) {
    return currentUser?.hasPermission(permission) ?? false;
  }
  
  /// Check if user has any of the permissions
  bool hasAnyPermission(List<String> permissions) {
    return currentUser?.hasAnyPermission(permissions) ?? false;
  }
  
  /// Check if user has role
  bool hasRole(String role) {
    return currentUser?.hasRole(role) ?? false;
  }
  
  /// Check if user has any of the roles
  bool hasAnyRole(List<String> roles) {
    return currentUser?.hasAnyRole(roles) ?? false;
  }
  
  /// Check if user is admin
  bool get isAdmin => currentUser?.isAdmin ?? false;
  
  /// Check if user is super admin
  bool get isSuperAdmin => currentUser?.isSuperAdmin ?? false;
  
  /// Navigate to appropriate home screen based on user role
  void _navigateToHomeScreen() {
    if (currentUser == null) return;
    
    final defaultRoute = AppRoutes.getDefaultRouteForRole(currentUser!.role);
    Get.offAllNamed(defaultRoute);
  }
  
  /// Set current user
  void _setCurrentUser(UserModel? user) {
    _currentUser.value = user;
  }
  
  /// Set authentication state
  void _setAuthenticated(bool authenticated) {
    _isAuthenticated.value = authenticated;
  }
  
  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }
  
  /// Set error message
  void _setError(String error) {
    _errorMessage.value = error;
  }
  
  /// Clear error message
  void _clearError() {
    _errorMessage.value = '';
  }
  
  /// Clear all data
  void _clearData() {
    _setCurrentUser(null);
    _setAuthenticated(false);
    _clearError();
  }
  
  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}