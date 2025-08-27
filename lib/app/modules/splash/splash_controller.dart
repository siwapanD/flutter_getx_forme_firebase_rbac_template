import 'package:get/get.dart';

import '../../../shared/controllers/auth_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/config/env.dart';

/// Splash controller handling app initialization
class SplashController extends GetxController {
  final RxBool _isLoading = true.obs;
  final RxString _statusMessage = 'Initializing...'.obs;
  
  bool get isLoading => _isLoading.value;
  String get statusMessage => _statusMessage.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }
  
  /// Initialize the application
  Future<void> _initializeApp() async {
    try {
      // Print environment configuration
      Env.printConfig();
      
      // Validate environment configuration
      if (!Env.validateConfig()) {
        _statusMessage.value = 'Configuration error';
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed(AppRoutes.serverError);
        return;
      }
      
      _statusMessage.value = 'Loading user data...';
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check authentication status
      final authController = Get.find<AuthController>();
      
      // Wait for authentication initialization
      int attempts = 0;
      while (authController.isLoading && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      
      _statusMessage.value = 'Preparing interface...';
      await Future.delayed(const Duration(milliseconds: 500));
      
      _isLoading.value = false;
      
      // Navigate based on authentication status
      if (authController.isAuthenticated && authController.currentUser != null) {
        final user = authController.currentUser!;
        
        // Check if email verification is required
        if (!user.emailVerified) {
          Get.offAllNamed(AppRoutes.verifyEmail);
          return;
        }
        
        // Navigate to default route for user role
        final defaultRoute = AppRoutes.getDefaultRouteForRole(user.role);
        Get.offAllNamed(defaultRoute);
      } else {
        // User not authenticated, go to login
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      _statusMessage.value = 'Initialization failed';
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(AppRoutes.serverError);
    }
  }
}