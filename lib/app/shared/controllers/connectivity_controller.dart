import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';

/// Connectivity controller managing network status and offline functionality
/// 
/// This controller monitors network connectivity, provides offline state
/// management, and handles network-related operations with appropriate
/// user feedback and error handling.
class ConnectivityController extends GetxController {
  // Reactive state
  final RxBool _isConnected = true.obs;
  final RxBool _isChecking = false.obs;
  final Rx<ConnectionType> _connectionType = ConnectionType.unknown.obs;
  final RxString _connectionStatus = 'Connected'.obs;
  final RxBool _showOfflineBanner = false.obs;
  
  // Timer for periodic connectivity checks
  Timer? _connectivityTimer;
  Timer? _bannerTimer;
  
  // Getters
  bool get isConnected => _isConnected.value;
  bool get isOffline => !_isConnected.value;
  bool get isChecking => _isChecking.value;
  ConnectionType get connectionType => _connectionType.value;
  String get connectionStatus => _connectionStatus.value;
  bool get showOfflineBanner => _showOfflineBanner.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeConnectivity();
    _startPeriodicCheck();
  }
  
  @override
  void onClose() {
    _connectivityTimer?.cancel();
    _bannerTimer?.cancel();
    super.onClose();
  }
  
  /// Initialize connectivity monitoring
  Future<void> _initializeConnectivity() async {
    await checkConnectivity();
  }
  
  /// Start periodic connectivity checking
  void _startPeriodicCheck() {
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => checkConnectivity(),
    );
  }
  
  /// Check current connectivity status
  Future<void> checkConnectivity() async {
    _setChecking(true);
    
    try {
      final isConnected = await _performConnectivityCheck();
      final connectionType = await _determineConnectionType();
      
      _updateConnectivityState(isConnected, connectionType);
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      _updateConnectivityState(false, ConnectionType.unknown);
    } finally {
      _setChecking(false);
    }
  }
  
  /// Perform actual connectivity check
  Future<bool> _performConnectivityCheck() async {
    try {
      // Try to reach Google's public DNS
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 10));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      return false;
    }
  }
  
  /// Determine connection type (simplified implementation)
  Future<ConnectionType> _determineConnectionType() async {
    try {
      // This is a simplified implementation
      // In a real app, you might use connectivity_plus package
      if (await _performConnectivityCheck()) {
        return ConnectionType.wifi; // Default to wifi when connected
      }
      return ConnectionType.none;
    } catch (e) {
      return ConnectionType.unknown;
    }
  }
  
  /// Update connectivity state and handle state changes
  void _updateConnectivityState(bool isConnected, ConnectionType connectionType) {
    final wasConnected = _isConnected.value;
    
    _isConnected.value = isConnected;
    _connectionType.value = connectionType;
    
    // Update status text
    _updateConnectionStatus();
    
    // Handle connectivity changes
    if (wasConnected != isConnected) {
      _handleConnectivityChange(isConnected);
    }
  }
  
  /// Update connection status text
  void _updateConnectionStatus() {
    if (_isConnected.value) {
      switch (_connectionType.value) {
        case ConnectionType.wifi:
          _connectionStatus.value = 'Connected via WiFi';
          break;
        case ConnectionType.mobile:
          _connectionStatus.value = 'Connected via Mobile Data';
          break;
        case ConnectionType.ethernet:
          _connectionStatus.value = 'Connected via Ethernet';
          break;
        case ConnectionType.unknown:
          _connectionStatus.value = 'Connected';
          break;
        case ConnectionType.none:
          _connectionStatus.value = 'No Connection';
          break;
      }
    } else {
      _connectionStatus.value = 'No Internet Connection';
    }
  }
  
  /// Handle connectivity state changes
  void _handleConnectivityChange(bool isConnected) {
    if (isConnected) {
      _onConnected();
    } else {
      _onDisconnected();
    }
  }
  
  /// Handle connection restored
  void _onConnected() {
    debugPrint('Internet connection restored');
    
    // Hide offline banner
    _hideOfflineBanner();
    
    // Show connection restored message
    Get.snackbar(
      'Connection Restored',
      'Internet connection has been restored',
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.wifi, color: Colors.white),
    );
    
    // Trigger data sync if needed
    _triggerDataSync();
  }
  
  /// Handle connection lost
  void _onDisconnected() {
    debugPrint('Internet connection lost');
    
    // Show offline banner
    _showOfflineBannerDelayed();
    
    // Show connection lost message
    Get.snackbar(
      'Connection Lost',
      'No internet connection. Some features may be limited.',
      backgroundColor: Colors.orange.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.wifi_off, color: Colors.white),
    );
  }
  
  /// Show offline banner with delay
  void _showOfflineBannerDelayed() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected.value) {
        _showOfflineBanner.value = true;
      }
    });
  }
  
  /// Hide offline banner
  void _hideOfflineBanner() {
    _bannerTimer?.cancel();
    _showOfflineBanner.value = false;
  }
  
  /// Trigger data synchronization when connection is restored
  void _triggerDataSync() {
    // Notify other controllers that connection is restored
    // They can implement their own sync logic
    Get.find<ConnectivityController>().update(['connectivity_restored']);
  }
  
  /// Retry connectivity check
  Future<void> retryConnection() async {
    Get.snackbar(
      'Checking Connection',
      'Attempting to reconnect...',
      backgroundColor: Colors.blue.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.refresh, color: Colors.white),
    );
    
    await checkConnectivity();
  }
  
  /// Check if network operation should be allowed
  bool shouldAllowNetworkOperation() {
    return _isConnected.value;
  }
  
  /// Execute network operation with connectivity check
  Future<T?> executeNetworkOperation<T>(
    Future<T> Function() operation, {
    String? offlineMessage,
    bool showOfflineSnackbar = true,
  }) async {
    if (!_isConnected.value) {
      if (showOfflineSnackbar) {
        Get.snackbar(
          'No Internet Connection',
          offlineMessage ?? 'This action requires an internet connection',
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.wifi_off, color: Colors.white),
        );
      }
      return null;
    }
    
    try {
      return await operation();
    } catch (e) {
      // Check if error is connectivity-related
      if (_isConnectivityError(e)) {
        // Trigger connectivity check
        await checkConnectivity();
      }
      rethrow;
    }
  }
  
  /// Check if error is connectivity-related
  bool _isConnectivityError(dynamic error) {
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is HttpException) return true;
    
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('connection') ||
           errorString.contains('timeout') ||
           errorString.contains('host lookup failed');
  }
  
  /// Get network status icon
  IconData getNetworkIcon() {
    if (_isConnected.value) {
      switch (_connectionType.value) {
        case ConnectionType.wifi:
          return Icons.wifi;
        case ConnectionType.mobile:
          return Icons.signal_cellular_4_bar;
        case ConnectionType.ethernet:
          return Icons.lan;
        case ConnectionType.unknown:
          return Icons.public;
        case ConnectionType.none:
          return Icons.wifi_off;
      }
    } else {
      return Icons.wifi_off;
    }
  }
  
  /// Get network status color
  Color getNetworkColor() {
    if (_isConnected.value) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
  
  /// Show connectivity settings dialog
  void showConnectivitySettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('Network Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(getNetworkIcon(), color: getNetworkColor()),
              title: Text(connectionStatus),
              subtitle: Text('Last checked: ${DateTime.now().toString().substring(11, 19)}'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Check Connection'),
              onTap: () {
                Get.back();
                retryConnection();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Device Network Settings'),
              onTap: () {
                Get.back();
                // In a real app, you might open device settings
                Get.snackbar(
                  'Network Settings',
                  'Please check your device network settings',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  /// Get offline banner widget
  Widget? getOfflineBanner() {
    if (!_showOfflineBanner.value) return null;
    
    return Container(
      width: double.infinity,
      color: Colors.orange,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 20),
          const SizedBox(width: AppConstants.paddingSmall),
          const Expanded(
            child: Text(
              'No internet connection. Some features may be limited.',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: retryConnection,
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Set loading state
  void _setChecking(bool checking) {
    _isChecking.value = checking;
  }
  
  /// Force connectivity state (for testing)
  void setConnectivityForTesting(bool isConnected, ConnectionType type) {
    _updateConnectivityState(isConnected, type);
  }
}

/// Connection type enumeration
enum ConnectionType {
  none,
  unknown,
  wifi,
  mobile,
  ethernet,
}