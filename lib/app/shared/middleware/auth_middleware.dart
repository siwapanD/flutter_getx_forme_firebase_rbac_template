import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../core/routes/app_routes.dart';

/// Authentication middleware for route protection
/// 
/// This middleware handles authentication checks and redirects users
/// to appropriate screens based on their authentication status.
/// It supports both requiring authentication and redirecting if already authenticated.
class AuthMiddleware extends GetMiddleware {
  final bool redirectIfAuthenticated;
  final String? redirectRoute;
  
  AuthMiddleware({
    this.redirectIfAuthenticated = false,
    this.redirectRoute,
  });
  
  @override
  int? get priority => 1;
  
  @override
  RouteSettings? redirect(String route) {
    try {
      final authController = Get.find<AuthController>();
      
      // Check if user is authenticated
      final isAuthenticated = authController.isAuthenticated;
      final currentUser = authController.currentUser;
      
      // If we should redirect authenticated users and user is authenticated
      if (redirectIfAuthenticated && isAuthenticated) {
        if (redirectRoute != null) {
          return RouteSettings(name: redirectRoute);
        }
        
        // Redirect to default route based on user role
        if (currentUser != null) {
          final defaultRoute = AppRoutes.getDefaultRouteForRole(currentUser.role);
          return RouteSettings(name: defaultRoute);
        }
        
        return const RouteSettings(name: AppRoutes.dashboard);
      }
      
      // If authentication is required and user is not authenticated
      if (!redirectIfAuthenticated && !isAuthenticated) {
        return const RouteSettings(name: AppRoutes.login);
      }
      
      // Check if user account is active (not blocked)
      if (isAuthenticated && currentUser != null) {
        if (!currentUser.isActive || currentUser.isBlocked) {
          // Force logout and redirect to login
          authController.signOut();
          
          Get.snackbar(
            'Account Inactive',
            'Your account has been deactivated. Please contact support.',
            backgroundColor: Colors.red.withOpacity(0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 5),
          );
          
          return const RouteSettings(name: AppRoutes.login);
        }
        
        // Check email verification for certain routes
        if (_requiresEmailVerification(route) && !currentUser.emailVerified) {
          return const RouteSettings(name: AppRoutes.verifyEmail);
        }
      }
      
      return null; // Continue to the requested route
    } catch (e) {
      debugPrint('AuthMiddleware error: $e');
      
      // If AuthController is not found, assume not authenticated
      if (!redirectIfAuthenticated) {
        return const RouteSettings(name: AppRoutes.login);
      }
      
      return null;
    }
  }
  
  /// Check if route requires email verification
  bool _requiresEmailVerification(String route) {
    const routesRequiringVerification = [
      AppRoutes.adminDashboard,
      AppRoutes.userManagement,
      AppRoutes.roleManagement,
      AppRoutes.systemSettings,
    ];
    
    return routesRequiringVerification.any((r) => route.startsWith(r));
  }
  
  @override
  GetPage? onPageCalled(GetPage page) {
    // Add any page-level modifications here
    return super.onPageCalled(page);
  }
  
  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    // Ensure AuthController is available
    try {
      Get.find<AuthController>();
    } catch (e) {
      // AuthController not found, this shouldn't happen with proper setup
      debugPrint('AuthController not found in AuthMiddleware: $e');
    }
    
    return super.onBindingsStart(bindings);
  }
  
  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    return super.onPageBuildStart(page);
  }
  
  @override
  Widget onPageBuilt(Widget page) {
    // Wrap page with authentication-aware widgets if needed
    return page;
  }
  
  @override
  void onPageDispose() {
    super.onPageDispose();
  }
}