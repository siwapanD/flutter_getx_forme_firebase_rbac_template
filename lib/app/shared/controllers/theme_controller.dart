import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/providers/storage_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Theme controller managing app theme and appearance settings
/// 
/// This controller handles theme switching, persistence, and responsive
/// design utilities. It provides reactive theme state management.
class ThemeController extends GetxController {
  final StorageProvider _storageProvider = Get.find<StorageProvider>();
  
  // Reactive state
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  final RxBool _isDarkMode = false.obs;
  final RxBool _isSystemTheme = true.obs;
  final RxDouble _textScaleFactor = 1.0.obs;
  final RxBool _useHighContrast = false.obs;
  final RxBool _reducedAnimations = false.obs;
  
  // Getters
  ThemeMode get themeMode => _themeMode.value;
  bool get isDarkMode => _isDarkMode.value;
  bool get isSystemTheme => _isSystemTheme.value;
  double get textScaleFactor => _textScaleFactor.value;
  bool get useHighContrast => _useHighContrast.value;
  bool get reducedAnimations => _reducedAnimations.value;
  
  // Theme data getters
  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;
  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;
  ColorScheme get colorScheme => currentTheme.colorScheme;
  TextTheme get textTheme => currentTheme.textTheme;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeSettings();
    _listenToSystemThemeChanges();
  }
  
  /// Load theme settings from storage
  Future<void> _loadThemeSettings() async {
    try {
      // Load theme mode
      final themeResult = await _storageProvider.retrieve<String>(
        AppConstants.storageKeyTheme,
        defaultValue: 'system',
      );
      
      if (themeResult.isSuccess && themeResult.value != null) {
        _setThemeModeFromString(themeResult.value!);
      }
      
      // Load accessibility settings
      final settingsResult = await _storageProvider.retrieveJson(
        AppConstants.storageKeySettings,
      );
      
      if (settingsResult.isSuccess && settingsResult.value != null) {
        final settings = settingsResult.value!;
        
        _textScaleFactor.value = (settings['textScaleFactor'] as double?) ?? 1.0;
        _useHighContrast.value = (settings['useHighContrast'] as bool?) ?? false;
        _reducedAnimations.value = (settings['reducedAnimations'] as bool?) ?? false;
      }
      
      _updateDarkModeState();
    } catch (e) {
      debugPrint('Failed to load theme settings: $e');
    }
  }
  
  /// Listen to system theme changes
  void _listenToSystemThemeChanges() {
    // Listen to system brightness changes
    if (isSystemTheme) {
      _updateDarkModeState();
    }
  }
  
  /// Set theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode.value = mode;
      _isSystemTheme.value = mode == ThemeMode.system;
      
      // Update dark mode state
      _updateDarkModeState();
      
      // Update GetX theme
      Get.changeThemeMode(mode);
      
      // Persist to storage
      await _storageProvider.store(
        AppConstants.storageKeyTheme,
        _themeModeToString(mode),
      );
      
      debugPrint('Theme mode changed to: ${_themeModeToString(mode)}');
    } catch (e) {
      debugPrint('Failed to set theme mode: $e');
    }
  }
  
  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
  
  /// Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }
  
  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }
  
  /// Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
  
  /// Set text scale factor
  Future<void> setTextScaleFactor(double scaleFactor) async {
    try {
      _textScaleFactor.value = scaleFactor.clamp(0.8, 2.0);
      await _saveAccessibilitySettings();
      
      // Show feedback
      Get.snackbar(
        'Text Size Updated',
        'Text scale factor set to ${_textScaleFactor.value.toStringAsFixed(1)}x',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Failed to set text scale factor: $e');
    }
  }
  
  /// Toggle high contrast mode
  Future<void> toggleHighContrast() async {
    try {
      _useHighContrast.value = !_useHighContrast.value;
      await _saveAccessibilitySettings();
      
      Get.snackbar(
        'High Contrast',
        _useHighContrast.value ? 'Enabled' : 'Disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Failed to toggle high contrast: $e');
    }
  }
  
  /// Toggle reduced animations
  Future<void> toggleReducedAnimations() async {
    try {
      _reducedAnimations.value = !_reducedAnimations.value;
      await _saveAccessibilitySettings();
      
      Get.snackbar(
        'Reduced Animations',
        _reducedAnimations.value ? 'Enabled' : 'Disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Failed to toggle reduced animations: $e');
    }
  }
  
  /// Get animation duration based on settings
  Duration getAnimationDuration(Duration defaultDuration) {
    if (_reducedAnimations.value) {
      return Duration.zero;
    }
    return defaultDuration;
  }
  
  /// Get responsive layout information
  LayoutInfo getLayoutInfo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    
    return LayoutInfo(
      screenSize: size,
      isMobile: AppTheme.isMobile(context),
      isTablet: AppTheme.isTablet(context),
      isDesktop: AppTheme.isDesktop(context),
      useWideLayout: AppTheme.useWideLayout(context),
      breakpoint: _getBreakpoint(width),
      columns: _getColumnCount(width),
      padding: _getResponsivePadding(width),
      margins: _getResponsiveMargins(width),
    );
  }
  
  /// Get current breakpoint
  Breakpoint _getBreakpoint(double width) {
    if (width < AppTheme.mobileBreakpoint) {
      return Breakpoint.xs;
    } else if (width < AppTheme.tabletBreakpoint) {
      return Breakpoint.sm;
    } else if (width < AppTheme.desktopBreakpoint) {
      return Breakpoint.md;
    } else {
      return Breakpoint.lg;
    }
  }
  
  /// Get column count for grid layouts
  int _getColumnCount(double width) {
    if (width < AppTheme.mobileBreakpoint) {
      return 1;
    } else if (width < AppTheme.tabletBreakpoint) {
      return 2;
    } else if (width < AppTheme.desktopBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }
  
  /// Get responsive padding
  EdgeInsets _getResponsivePadding(double width) {
    if (width < AppTheme.mobileBreakpoint) {
      return const EdgeInsets.all(AppConstants.paddingMedium);
    } else if (width < AppTheme.tabletBreakpoint) {
      return const EdgeInsets.all(AppConstants.paddingLarge);
    } else {
      return const EdgeInsets.all(AppConstants.paddingXLarge);
    }
  }
  
  /// Get responsive margins
  EdgeInsets _getResponsiveMargins(double width) {
    if (width < AppTheme.mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium);
    } else if (width < AppTheme.tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge);
    } else {
      return const EdgeInsets.symmetric(horizontal: AppConstants.paddingXLarge);
    }
  }
  
  /// Get appropriate icon size for current layout
  double getIconSize(IconSize size) {
    switch (size) {
      case IconSize.small:
        return AppConstants.iconSizeSmall;
      case IconSize.medium:
        return AppConstants.iconSizeMedium;
      case IconSize.large:
        return AppConstants.iconSizeLarge;
      case IconSize.xLarge:
        return AppConstants.iconSizeXLarge;
    }
  }
  
  /// Get appropriate text style for current theme and accessibility settings
  TextStyle? getTextStyle(TextStyleType type) {
    TextStyle? baseStyle;
    
    switch (type) {
      case TextStyleType.headline1:
        baseStyle = textTheme.displayLarge;
        break;
      case TextStyleType.headline2:
        baseStyle = textTheme.displayMedium;
        break;
      case TextStyleType.headline3:
        baseStyle = textTheme.displaySmall;
        break;
      case TextStyleType.headline4:
        baseStyle = textTheme.headlineMedium;
        break;
      case TextStyleType.headline5:
        baseStyle = textTheme.headlineSmall;
        break;
      case TextStyleType.headline6:
        baseStyle = textTheme.titleLarge;
        break;
      case TextStyleType.body1:
        baseStyle = textTheme.bodyLarge;
        break;
      case TextStyleType.body2:
        baseStyle = textTheme.bodyMedium;
        break;
      case TextStyleType.caption:
        baseStyle = textTheme.bodySmall;
        break;
      case TextStyleType.button:
        baseStyle = textTheme.labelLarge;
        break;
    }
    
    if (baseStyle == null) return null;
    
    // Apply text scale factor
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * _textScaleFactor.value,
    );
  }
  
  /// Update dark mode state based on current theme mode and system brightness
  void _updateDarkModeState() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        _isDarkMode.value = false;
        break;
      case ThemeMode.dark:
        _isDarkMode.value = true;
        break;
      case ThemeMode.system:
        final brightness = Get.mediaQuery.platformBrightness;
        _isDarkMode.value = brightness == Brightness.dark;
        break;
    }
  }
  
  /// Convert ThemeMode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
  
  /// Convert string to ThemeMode
  void _setThemeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        _themeMode.value = ThemeMode.light;
        _isSystemTheme.value = false;
        break;
      case 'dark':
        _themeMode.value = ThemeMode.dark;
        _isSystemTheme.value = false;
        break;
      case 'system':
      default:
        _themeMode.value = ThemeMode.system;
        _isSystemTheme.value = true;
        break;
    }
  }
  
  /// Save accessibility settings to storage
  Future<void> _saveAccessibilitySettings() async {
    try {
      final settings = {
        'textScaleFactor': _textScaleFactor.value,
        'useHighContrast': _useHighContrast.value,
        'reducedAnimations': _reducedAnimations.value,
      };
      
      await _storageProvider.storeJson(
        AppConstants.storageKeySettings,
        settings,
      );
    } catch (e) {
      debugPrint('Failed to save accessibility settings: $e');
    }
  }
  
  /// Reset all theme settings to defaults
  Future<void> resetToDefaults() async {
    try {
      await setThemeMode(ThemeMode.system);
      _textScaleFactor.value = 1.0;
      _useHighContrast.value = false;
      _reducedAnimations.value = false;
      
      await _saveAccessibilitySettings();
      
      Get.snackbar(
        'Settings Reset',
        'All theme settings have been reset to defaults',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Failed to reset theme settings: $e');
    }
  }
}

/// Layout information for responsive design
class LayoutInfo {
  final Size screenSize;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool useWideLayout;
  final Breakpoint breakpoint;
  final int columns;
  final EdgeInsets padding;
  final EdgeInsets margins;
  
  const LayoutInfo({
    required this.screenSize,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.useWideLayout,
    required this.breakpoint,
    required this.columns,
    required this.padding,
    required this.margins,
  });
}

/// Responsive breakpoints
enum Breakpoint { xs, sm, md, lg }

/// Icon sizes
enum IconSize { small, medium, large, xLarge }

/// Text style types
enum TextStyleType {
  headline1,
  headline2,
  headline3,
  headline4,
  headline5,
  headline6,
  body1,
  body2,
  caption,
  button,
}