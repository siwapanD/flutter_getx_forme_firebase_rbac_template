import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/controllers/auth_controller.dart';
import '../../../../core/utils/debouncer.dart';

/// Login controller handling login form and authentication
class LoginController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  // Reactive state
  final RxBool _isPasswordVisible = false.obs;
  final RxBool _rememberMe = false.obs;
  final RxString _emailError = ''.obs;
  final RxString _passwordError = ''.obs;
  
  // Debouncer for input validation
  final _validationDebouncer = Debouncer(delay: const Duration(milliseconds: 500));
  
  // Getters
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get rememberMe => _rememberMe.value;
  String get emailError => _emailError.value;
  String get passwordError => _passwordError.value;
  bool get isLoading => _authController.isLoading;
  
  @override
  void onInit() {
    super.onInit();
    _setupValidation();
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    _validationDebouncer.dispose();
    super.onClose();
  }
  
  /// Setup real-time validation
  void _setupValidation() {
    emailController.addListener(() {
      _validationDebouncer(() => _validateEmail());
    });
    
    passwordController.addListener(() {
      _validationDebouncer(() => _validatePassword());
    });
  }
  
  /// Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }
  
  /// Toggle remember me
  void toggleRememberMe() {
    _rememberMe.value = !_rememberMe.value;
  }
  
  /// Validate email
  void _validateEmail() {
    final email = emailController.text.trim();
    
    if (email.isEmpty) {
      _emailError.value = '';
      return;
    }
    
    if (!_isValidEmail(email)) {
      _emailError.value = 'Please enter a valid email address';
    } else {
      _emailError.value = '';
    }
  }
  
  /// Validate password
  void _validatePassword() {
    final password = passwordController.text;
    
    if (password.isEmpty) {
      _passwordError.value = '';
      return;
    }
    
    if (password.length < 6) {
      _passwordError.value = 'Password must be at least 6 characters';
    } else {
      _passwordError.value = '';
    }
  }
  
  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
  
  /// Sign in with email and password
  Future<void> signInWithEmail() async {
    if (!formKey.currentState!.validate()) return;
    
    final email = emailController.text.trim();
    final password = passwordController.text;
    
    await _authController.signInWithEmail(email, password);
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    await _authController.signInWithGoogle();
  }
  
  /// Sign in with Apple
  Future<void> signInWithApple() async {
    await _authController.signInWithApple();
  }
  
  /// Navigate to register page
  void goToRegister() {
    Get.toNamed('/register');
  }
  
  /// Navigate to forgot password page
  void goToForgotPassword() {
    Get.toNamed('/forgot-password');
  }
  
  /// Form validation
  String? validateEmailField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    if (!_isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  String? validatePasswordField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
}