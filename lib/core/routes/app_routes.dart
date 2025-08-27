/// Application route constants and path management
/// 
/// This class contains all the route constants used throughout the application.
/// It provides a centralized way to manage navigation paths and ensures
/// type safety when navigating between screens.
abstract class AppRoutes {
  // Authentication routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String resetPassword = '/reset-password';
  
  // Main application routes
  static const String dashboard = '/dashboard';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Admin routes (RBAC protected)
  static const String adminDashboard = '/admin/dashboard';
  static const String userManagement = '/admin/users';
  static const String roleManagement = '/admin/roles';
  static const String systemSettings = '/admin/settings';
  
  // Feature routes
  static const String notifications = '/notifications';
  static const String reports = '/reports';
  static const String analytics = '/analytics';
  static const String calendar = '/calendar';
  
  // Utility routes
  static const String notFound = '/404';
  static const String unauthorized = '/401';
  static const String serverError = '/500';
  
  /// Get the route name without parameters
  static String getRouteName(String fullRoute) {
    if (fullRoute.contains('?')) {
      return fullRoute.split('?').first;
    }
    return fullRoute;
  }
  
  /// Check if a route requires authentication
  static bool requiresAuth(String route) {
    const unauthenticatedRoutes = [
      splash,
      login,
      register,
      forgotPassword,
      verifyEmail,
      resetPassword,
      notFound,
      unauthorized,
      serverError,
    ];
    
    return !unauthenticatedRoutes.contains(getRouteName(route));
  }
  
  /// Check if a route is for admin only
  static bool isAdminRoute(String route) {
    const adminRoutes = [
      adminDashboard,
      userManagement,
      roleManagement,
      systemSettings,
    ];
    
    return adminRoutes.any((adminRoute) => 
        getRouteName(route).startsWith(adminRoute));
  }
  
  /// Get the default route for a user role
  static String getDefaultRouteForRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'super_admin':
        return adminDashboard;
      case 'user':
      case 'member':
        return dashboard;
      default:
        return home;
    }
  }
  
  /// Navigation parameters for type-safe route navigation
  static Map<String, String> buildParams({
    String? id,
    String? tab,
    String? filter,
    Map<String, String>? extra,
  }) {
    final params = <String, String>{};
    
    if (id != null) params['id'] = id;
    if (tab != null) params['tab'] = tab;
    if (filter != null) params['filter'] = filter;
    if (extra != null) params.addAll(extra);
    
    return params;
  }
}