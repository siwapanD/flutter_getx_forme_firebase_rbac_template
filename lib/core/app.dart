import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'config/env.dart';
import 'constants/app_constants.dart';

/// Main application class that bootstraps the Flutter app
/// with GetX, Firebase, themes, and error boundary
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // App configuration
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppConstants.supportedLocales,
      locale: AppConstants.defaultLocale,
      fallbackLocale: AppConstants.fallbackLocale,
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Navigation
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      
      // Error handling
      builder: (context, child) => _ErrorBoundary(child: child),
      
      // System UI
      onInit: () => _configureSystemUI(),
    );
  }

  /// Configure system UI styling
  void _configureSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

/// Error boundary widget to handle uncaught errors gracefully
class _ErrorBoundary extends StatelessWidget {
  const _ErrorBoundary({required this.child});
  
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling, // Prevent text scaling issues
      ),
      child: child ?? const _ErrorScreen(),
    );
  }
}

/// Error screen shown when the app encounters fatal errors
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please restart the application',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bootstrap function to initialize Firebase and start the app
Future<void> bootstrap() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  if (Env.enableFirebase) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Log error but continue without Firebase in development
      debugPrint('Firebase initialization failed: $e');
    }
  }
  
  // Handle Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };
  
  // Run the app
  runApp(const App());
}