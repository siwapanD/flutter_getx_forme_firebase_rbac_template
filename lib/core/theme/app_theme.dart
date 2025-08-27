import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Comprehensive theme system with accessibility support
/// 
/// This class provides a complete theme configuration for both light and dark modes
/// with accessibility considerations, responsive design, and consistent styling.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();
  
  // Color schemes
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1976D2),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFBBDEFB),
    onPrimaryContainer: Color(0xFF0D47A1),
    secondary: Color(0xFF26A69A),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFB2DFDB),
    onSecondaryContainer: Color(0xFF004D40),
    tertiary: Color(0xFFFF7043),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFCCBC),
    onTertiaryContainer: Color(0xFFBF360C),
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFCDD2),
    onErrorContainer: Color(0xFFB71C1C),
    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF212121),
    surfaceContainerHighest: Color(0xFFE0E0E0),
    onSurfaceVariant: Color(0xFF757575),
    outline: Color(0xFFBDBDBD),
    outlineVariant: Color(0xFFE0E0E0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF212121),
    onInverseSurface: Color(0xFFFAFAFA),
    inversePrimary: Color(0xFF90CAF9),
  );
  
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF90CAF9),
    onPrimary: Color(0xFF0D47A1),
    primaryContainer: Color(0xFF1565C0),
    onPrimaryContainer: Color(0xFFE3F2FD),
    secondary: Color(0xFF4DB6AC),
    onSecondary: Color(0xFF004D40),
    secondaryContainer: Color(0xFF00695C),
    onSecondaryContainer: Color(0xFFE0F2F1),
    tertiary: Color(0xFFFFAB91),
    onTertiary: Color(0xFFBF360C),
    tertiaryContainer: Color(0xFFE64A19),
    onTertiaryContainer: Color(0xFFFBE9E7),
    error: Color(0xFFEF5350),
    onError: Color(0xFFB71C1C),
    errorContainer: Color(0xFFC62828),
    onErrorContainer: Color(0xFFFFEBEE),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE0E0E0),
    surfaceContainerHighest: Color(0xFF2C2C2C),
    onSurfaceVariant: Color(0xFFBDBDBD),
    outline: Color(0xFF757575),
    outlineVariant: Color(0xFF424242),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE0E0E0),
    onInverseSurface: Color(0xFF121212),
    inversePrimary: Color(0xFF1976D2),
  );
  
  // Typography
  static TextTheme get _baseTextTheme => GoogleFonts.robotoTextTheme();
  
  static TextTheme get _lightTextTheme => _baseTextTheme.copyWith(
    displayLarge: _baseTextTheme.displayLarge?.copyWith(
      color: _lightColorScheme.onSurface,
      fontWeight: FontWeight.w300,
    ),
    displayMedium: _baseTextTheme.displayMedium?.copyWith(
      color: _lightColorScheme.onSurface,
      fontWeight: FontWeight.w300,
    ),
    displaySmall: _baseTextTheme.displaySmall?.copyWith(
      color: _lightColorScheme.onSurface,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: _baseTextTheme.headlineLarge?.copyWith(
      color: _lightColorScheme.onSurface,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: _baseTextTheme.headlineMedium?.copyWith(
      color: _lightColorScheme.onSurface,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: _baseTextTheme.headlineSmall?.copyWith(
      color: _lightColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: _baseTextTheme.titleLarge?.copyWith(
      color: _lightColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: _baseTextTheme.titleMedium?.copyWith(
      color: _lightColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: _baseTextTheme.titleSmall?.copyWith(
      color: _lightColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: _baseTextTheme.bodyLarge?.copyWith(
      color: _lightColorScheme.onSurface,
    ),
    bodyMedium: _baseTextTheme.bodyMedium?.copyWith(
      color: _lightColorScheme.onSurface,
    ),
    bodySmall: _baseTextTheme.bodySmall?.copyWith(
      color: _lightColorScheme.onSurfaceVariant,
    ),
    labelLarge: _baseTextTheme.labelLarge?.copyWith(
      color: _lightColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: _baseTextTheme.labelMedium?.copyWith(
      color: _lightColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: _baseTextTheme.labelSmall?.copyWith(
      color: _lightColorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    ),
  );
  
  static TextTheme get _darkTextTheme => _baseTextTheme.copyWith(
    displayLarge: _baseTextTheme.displayLarge?.copyWith(
      color: _darkColorScheme.onSurface,
      fontWeight: FontWeight.w300,
    ),
    displayMedium: _baseTextTheme.displayMedium?.copyWith(
      color: _darkColorScheme.onSurface,
      fontWeight: FontWeight.w300,
    ),
    displaySmall: _baseTextTheme.displaySmall?.copyWith(
      color: _darkColorScheme.onSurface,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: _baseTextTheme.headlineLarge?.copyWith(
      color: _darkColorScheme.onSurface,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: _baseTextTheme.headlineMedium?.copyWith(
      color: _darkColorScheme.onSurface,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: _baseTextTheme.headlineSmall?.copyWith(
      color: _darkColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: _baseTextTheme.titleLarge?.copyWith(
      color: _darkColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: _baseTextTheme.titleMedium?.copyWith(
      color: _darkColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: _baseTextTheme.titleSmall?.copyWith(
      color: _darkColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: _baseTextTheme.bodyLarge?.copyWith(
      color: _darkColorScheme.onSurface,
    ),
    bodyMedium: _baseTextTheme.bodyMedium?.copyWith(
      color: _darkColorScheme.onSurface,
    ),
    bodySmall: _baseTextTheme.bodySmall?.copyWith(
      color: _darkColorScheme.onSurfaceVariant,
    ),
    labelLarge: _baseTextTheme.labelLarge?.copyWith(
      color: _darkColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: _baseTextTheme.labelMedium?.copyWith(
      color: _darkColorScheme.onSurface,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: _baseTextTheme.labelSmall?.copyWith(
      color: _darkColorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    ),
  );
  
  // Light theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    textTheme: _lightTextTheme,
    
    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.surface,
      foregroundColor: _lightColorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle: _lightTextTheme.titleLarge,
    ),
    
    // Card theme
    cardTheme: CardThemeData(
      color: _lightColorScheme.surface,
      shadowColor: _lightColorScheme.shadow.withOpacity(0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _lightColorScheme.onPrimary,
        backgroundColor: _lightColorScheme.primary,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: _lightTextTheme.labelLarge,
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightColorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _lightColorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _lightColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _lightColorScheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: _lightTextTheme.bodyMedium,
      hintStyle: _lightTextTheme.bodyMedium?.copyWith(
        color: _lightColorScheme.onSurfaceVariant,
      ),
    ),
    
    // Navigation bar theme
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _lightColorScheme.surface,
      indicatorColor: _lightColorScheme.primaryContainer,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _lightTextTheme.labelMedium?.copyWith(
            color: _lightColorScheme.onPrimaryContainer,
          );
        }
        return _lightTextTheme.labelMedium?.copyWith(
          color: _lightColorScheme.onSurfaceVariant,
        );
      }),
    ),
    
    // Divider theme
    dividerTheme: DividerThemeData(
      color: _lightColorScheme.outlineVariant,
      thickness: 1,
    ),
    
    // Visual density for better accessibility
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
  
  // Dark theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    textTheme: _darkTextTheme,
    
    // App bar theme
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle: _darkTextTheme.titleLarge,
    ),
    
    // Card theme
    cardTheme: CardThemeData(
      color: _darkColorScheme.surface,
      shadowColor: _darkColorScheme.shadow.withOpacity(0.3),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _darkColorScheme.onPrimary,
        backgroundColor: _darkColorScheme.primary,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: _darkTextTheme.labelLarge,
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkColorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _darkColorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _darkColorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _darkColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _darkColorScheme.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: _darkTextTheme.bodyMedium,
      hintStyle: _darkTextTheme.bodyMedium?.copyWith(
        color: _darkColorScheme.onSurfaceVariant,
      ),
    ),
    
    // Navigation bar theme
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _darkColorScheme.surface,
      indicatorColor: _darkColorScheme.primaryContainer,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _darkTextTheme.labelMedium?.copyWith(
            color: _darkColorScheme.onPrimaryContainer,
          );
        }
        return _darkTextTheme.labelMedium?.copyWith(
          color: _darkColorScheme.onSurfaceVariant,
        );
      }),
    ),
    
    // Divider theme
    dividerTheme: DividerThemeData(
      color: _darkColorScheme.outlineVariant,
      thickness: 1,
    ),
    
    // Visual density for better accessibility
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
  
  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  
  // Helper methods for responsive design
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  // Layout helper for 900px breakpoint requirement
  static bool useWideLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900.0;
  }
  
  // Common paddings and margins
  static const EdgeInsets pagePadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: 24.0);
  
  // Common border radius
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(12.0));
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(8.0));
}