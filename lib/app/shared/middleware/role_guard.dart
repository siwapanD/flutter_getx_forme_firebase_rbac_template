import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';

/// Role-based access control middleware
/// 
/// This middleware enforces role-based access control by checking if the
/// current user has the required roles or permissions to access a route.
/// It redirects unauthorized users to appropriate error pages.
class RoleGuard extends GetMiddleware {
  final List<String>? allowedRoles;
  final List<String>? requiredPermissions;
  final bool requireAllPermissions;
  final String? unauthorizedRoute;
  
  RoleGuard({
    this.allowedRoles,
    this.requiredPermissions,
    this.requireAllPermissions = false,
    this.unauthorizedRoute,
  }) : assert(
          allowedRoles != null || requiredPermissions != null,
          'Either allowedRoles or requiredPermissions must be provided',
        );
  
  @override
  int? get priority => 2; // Execute after AuthMiddleware
  
  @override
  RouteSettings? redirect(String route) {
    try {
      final authController = Get.find<AuthController>();
      
      // User must be authenticated to check roles/permissions
      if (!authController.isAuthenticated || authController.currentUser == null) {
        return const RouteSettings(name: AppRoutes.login);
      }
      
      final user = authController.currentUser!;
      
      // Check if user account is active
      if (!user.isActive || user.isBlocked) {
        return const RouteSettings(name: AppRoutes.unauthorized);
      }
      
      // Check role-based access
      if (allowedRoles != null && !_hasRequiredRole(user)) {
        return _getUnauthorizedRoute(route);
      }
      
      // Check permission-based access
      if (requiredPermissions != null && !_hasRequiredPermissions(user)) {
        return _getUnauthorizedRoute(route);
      }
      
      return null; // Access granted
    } catch (e) {
      debugPrint('RoleGuard error: $e');
      return const RouteSettings(name: AppRoutes.unauthorized);
    }
  }
  
  /// Check if user has required role
  bool _hasRequiredRole(UserModel user) {
    if (allowedRoles == null || allowedRoles!.isEmpty) return true;
    
    // Check direct role match
    if (allowedRoles!.contains(user.role)) return true;
    
    // Check role hierarchy (higher roles can access lower role routes)
    final userRoleLevel = AppConstants.getRoleHierarchy(user.role);
    
    for (final allowedRole in allowedRoles!) {
      final allowedRoleLevel = AppConstants.getRoleHierarchy(allowedRole);
      if (userRoleLevel >= allowedRoleLevel) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Check if user has required permissions
  bool _hasRequiredPermissions(UserModel user) {
    if (requiredPermissions == null || requiredPermissions!.isEmpty) return true;
    
    if (requireAllPermissions) {
      // User must have all required permissions
      return user.hasAllPermissions(requiredPermissions!);
    } else {
      // User must have at least one required permission
      return user.hasAnyPermission(requiredPermissions!);
    }
  }
  
  /// Get appropriate unauthorized route
  RouteSettings _getUnauthorizedRoute(String requestedRoute) {
    // Use custom unauthorized route if provided
    if (unauthorizedRoute != null) {
      return RouteSettings(name: unauthorizedRoute);
    }
    
    // Show different error pages based on context
    if (_isAdminRoute(requestedRoute)) {
      return const RouteSettings(name: AppRoutes.unauthorized);
    }
    
    return const RouteSettings(name: AppRoutes.unauthorized);
  }
  
  /// Check if route is an admin route
  bool _isAdminRoute(String route) {
    return route.startsWith('/admin/');
  }
  
  @override
  GetPage? onPageCalled(GetPage page) {
    return super.onPageCalled(page);
  }
  
  @override
  List<Bindings>? onBindingsStart(List<Bindings>? bindings) {
    return super.onBindingsStart(bindings);
  }
  
  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    return super.onPageBuildStart(page);
  }
  
  @override
  Widget onPageBuilt(Widget page) {
    // Wrap page with role-aware widgets if needed
    return _RoleAwarePage(
      allowedRoles: allowedRoles,
      requiredPermissions: requiredPermissions,
      child: page,
    );
  }
  
  @override
  void onPageDispose() {
    super.onPageDispose();
  }
}

/// Widget wrapper that provides role-aware context
class _RoleAwarePage extends StatelessWidget {
  final List<String>? allowedRoles;
  final List<String>? requiredPermissions;
  final Widget child;
  
  const _RoleAwarePage({
    required this.child,
    this.allowedRoles,
    this.requiredPermissions,
  });
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        // Monitor user role/permission changes
        if (!authController.isAuthenticated || authController.currentUser == null) {
          // User logged out while on page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.login);
          });
          
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final user = authController.currentUser!;
        
        // Check if user still has access
        if (!_hasAccess(user)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offNamed(AppRoutes.unauthorized);
          });
          
          return const Scaffold(
            body: Center(
              child: Text('Access Denied'),
            ),
          );
        }
        
        return child;
      },
    );
  }
  
  /// Check if user has access based on current roles/permissions
  bool _hasAccess(UserModel user) {
    // Check if user account is still active
    if (!user.isActive || user.isBlocked) return false;
    
    // Check role access
    if (allowedRoles != null && allowedRoles!.isNotEmpty) {
      if (!allowedRoles!.contains(user.role)) {
        // Check role hierarchy
        final userRoleLevel = AppConstants.getRoleHierarchy(user.role);
        bool hasRoleAccess = false;
        
        for (final allowedRole in allowedRoles!) {
          final allowedRoleLevel = AppConstants.getRoleHierarchy(allowedRole);
          if (userRoleLevel >= allowedRoleLevel) {
            hasRoleAccess = true;
            break;
          }
        }
        
        if (!hasRoleAccess) return false;
      }
    }
    
    // Check permission access
    if (requiredPermissions != null && requiredPermissions!.isNotEmpty) {
      if (!user.hasAnyPermission(requiredPermissions!)) {
        return false;
      }
    }
    
    return true;
  }
}

/// Helper class for role and permission checks
class RoleGuardHelper {
  /// Check if current user has role
  static bool hasRole(String role) {
    try {
      final authController = Get.find<AuthController>();
      return authController.hasRole(role);
    } catch (e) {
      return false;
    }
  }
  
  /// Check if current user has any of the roles
  static bool hasAnyRole(List<String> roles) {
    try {
      final authController = Get.find<AuthController>();
      return authController.hasAnyRole(roles);
    } catch (e) {
      return false;
    }
  }
  
  /// Check if current user has permission
  static bool hasPermission(String permission) {
    try {
      final authController = Get.find<AuthController>();
      return authController.hasPermission(permission);
    } catch (e) {
      return false;
    }
  }
  
  /// Check if current user has any of the permissions
  static bool hasAnyPermission(List<String> permissions) {
    try {
      final authController = Get.find<AuthController>();
      return authController.hasAnyPermission(permissions);
    } catch (e) {
      return false;
    }
  }
  
  /// Check if current user is admin
  static bool get isAdmin {
    try {
      final authController = Get.find<AuthController>();
      return authController.isAdmin;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if current user is super admin
  static bool get isSuperAdmin {
    try {
      final authController = Get.find<AuthController>();
      return authController.isSuperAdmin;
    } catch (e) {
      return false;
    }
  }
  
  /// Show unauthorized access message
  static void showUnauthorizedMessage([String? message]) {
    Get.snackbar(
      'Access Denied',
      message ?? 'You do not have permission to access this feature.',
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.lock, color: Colors.white),
    );
  }
  
  /// Navigate to unauthorized page
  static void navigateToUnauthorized() {
    Get.toNamed(AppRoutes.unauthorized);
  }
}