import 'package:get/get.dart';

import 'app_routes.dart';
import '../bindings/initial_binding.dart';
import '../../app/modules/splash/splash_binding.dart';
import '../../app/modules/splash/splash_page.dart';
import '../../app/modules/auth/login/login_binding.dart';
import '../../app/modules/auth/login/login_page.dart';
import '../../app/modules/auth/register/register_binding.dart';
import '../../app/modules/auth/register/register_page.dart';
import '../../app/modules/dashboard/dashboard_binding.dart';
import '../../app/modules/dashboard/dashboard_page.dart';
import '../../app/modules/home/home_binding.dart';
import '../../app/modules/home/home_page.dart';
import '../../app/modules/profile/profile_binding.dart';
import '../../app/modules/profile/profile_page.dart';
import '../../app/modules/admin/admin_dashboard/admin_dashboard_binding.dart';
import '../../app/modules/admin/admin_dashboard/admin_dashboard_page.dart';
import '../../app/modules/error/error_page.dart';
import '../../app/shared/middleware/auth_middleware.dart';
import '../../app/shared/middleware/role_guard.dart';

/// Page definitions with RoleGuard integration
/// 
/// This class defines all the pages in the application with their corresponding
/// routes, bindings, and middleware for authentication and role-based access control.
abstract class AppPages {
  /// All application routes with their page definitions
  static final routes = [
    // Splash screen - no authentication required
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    
    // Authentication routes - redirect if already authenticated
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      middlewares: [
        AuthMiddleware(redirectIfAuthenticated: true),
      ],
    ),
    
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
      middlewares: [
        AuthMiddleware(redirectIfAuthenticated: true),
      ],
    ),
    
    // Main application routes - require authentication
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleGuard(allowedRoles: ['user', 'admin', 'super_admin']),
      ],
    ),
    
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
    ),
    
    // Admin routes - require admin role
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardPage(),
      binding: AdminDashboardBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleGuard(allowedRoles: ['admin', 'super_admin']),
      ],
    ),
    
    GetPage(
      name: AppRoutes.userManagement,
      page: () => const AdminDashboardPage(initialTab: 'users'),
      binding: AdminDashboardBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleGuard(allowedRoles: ['admin', 'super_admin']),
      ],
    ),
    
    GetPage(
      name: AppRoutes.roleManagement,
      page: () => const AdminDashboardPage(initialTab: 'roles'),
      binding: AdminDashboardBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleGuard(allowedRoles: ['super_admin']),
      ],
    ),
    
    GetPage(
      name: AppRoutes.systemSettings,
      page: () => const AdminDashboardPage(initialTab: 'settings'),
      binding: AdminDashboardBinding(),
      middlewares: [
        AuthMiddleware(),
        RoleGuard(allowedRoles: ['super_admin']),
      ],
    ),
    
    // Error pages - no authentication required
    GetPage(
      name: AppRoutes.notFound,
      page: () => const ErrorPage(
        errorCode: '404',
        title: 'Page Not Found',
        message: 'The page you are looking for does not exist.',
      ),
    ),
    
    GetPage(
      name: AppRoutes.unauthorized,
      page: () => const ErrorPage(
        errorCode: '401',
        title: 'Unauthorized',
        message: 'You do not have permission to access this page.',
      ),
    ),
    
    GetPage(
      name: AppRoutes.serverError,
      page: () => const ErrorPage(
        errorCode: '500',
        title: 'Server Error',
        message: 'Something went wrong on our end. Please try again later.',
      ),
    ),
  ];
  
  /// Get route by name for programmatic navigation
  static GetPage? getRouteByName(String name) {
    try {
      return routes.firstWhere((route) => route.name == name);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if a route exists
  static bool routeExists(String name) {
    return routes.any((route) => route.name == name);
  }
  
  /// Get all routes that match a pattern
  static List<GetPage> getRoutesByPattern(String pattern) {
    return routes.where((route) => 
        route.name.contains(pattern)).toList();
  }
  
  /// Get all admin routes
  static List<GetPage> get adminRoutes {
    return routes.where((route) => 
        route.name.startsWith('/admin')).toList();
  }
  
  /// Get all public routes (no authentication required)
  static List<GetPage> get publicRoutes {
    const publicRouteNames = [
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.verifyEmail,
      AppRoutes.resetPassword,
      AppRoutes.notFound,
      AppRoutes.unauthorized,
      AppRoutes.serverError,
    ];
    
    return routes.where((route) => 
        publicRouteNames.contains(route.name)).toList();
  }
}