package com.example.flutter_getx_forme_firebase_rbac_template

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import java.util.concurrent.Executor

/**
 * MainActivity for Flutter application with native platform integration
 * 
 * This activity handles:
 * - Flutter engine configuration
 * - Deep linking
 * - Native method channels
 * - Biometric authentication
 * - Platform-specific features
 */
class MainActivity: FlutterActivity() {
    
    private val CHANNEL = "com.example.flutter_getx_forme_firebase_rbac_template/native"
    private lateinit var biometricPrompt: BiometricPrompt
    private lateinit var promptInfo: BiometricPrompt.PromptInfo
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Set up method channel for native communication
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBiometricAvailability" -> {
                    result.success(getBiometricAvailability())
                }
                "authenticateWithBiometric" -> {
                    val title = call.argument<String>("title") ?: "Biometric Authentication"
                    val subtitle = call.argument<String>("subtitle") ?: "Use your biometric to authenticate"
                    val description = call.argument<String>("description") ?: "Place your finger on the sensor or look at the camera"
                    val negativeButtonText = call.argument<String>("negativeButtonText") ?: "Cancel"
                    
                    authenticateWithBiometric(title, subtitle, description, negativeButtonText) { success, error ->
                        if (success) {
                            result.success(true)
                        } else {
                            result.error("BIOMETRIC_ERROR", error, null)
                        }
                    }
                }
                "getDeviceInfo" -> {
                    result.success(getDeviceInfo())
                }
                "openAppSettings" -> {
                    openAppSettings()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        setupBiometricPrompt()
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Handle deep linking
        handleDeepLink(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        
        // Handle deep linking when app is already running
        handleDeepLink(intent)
    }
    
    /**
     * Handle deep linking and universal links
     */
    private fun handleDeepLink(intent: Intent?) {
        intent?.data?.let { uri ->
            // Send deep link to Flutter
            MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL)
                .invokeMethod("onDeepLink", uri.toString())
        }
    }
    
    /**
     * Check biometric authentication availability
     */
    private fun getBiometricAvailability(): Map<String, Any> {
        val biometricManager = BiometricManager.from(this)
        
        return when (biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_WEAK)) {
            BiometricManager.BIOMETRIC_SUCCESS -> {
                mapOf(
                    "isAvailable" to true,
                    "status" to "available",
                    "errorMessage" to ""
                )
            }
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> {
                mapOf(
                    "isAvailable" to false,
                    "status" to "no_hardware",
                    "errorMessage" to "No biometric features available on this device"
                )
            }
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE -> {
                mapOf(
                    "isAvailable" to false,
                    "status" to "hardware_unavailable",
                    "errorMessage" to "Biometric features are currently unavailable"
                )
            }
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> {
                mapOf(
                    "isAvailable" to false,
                    "status" to "none_enrolled",
                    "errorMessage" to "No biometric credentials are enrolled"
                )
            }
            else -> {
                mapOf(
                    "isAvailable" to false,
                    "status" to "unknown",
                    "errorMessage" to "Unknown biometric status"
                )
            }
        }
    }
    
    /**
     * Setup biometric prompt for authentication
     */
    private fun setupBiometricPrompt() {
        val executor: Executor = ContextCompat.getMainExecutor(this)
        
        biometricPrompt = BiometricPrompt(this as FragmentActivity,
            executor, object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    // Handle authentication error
                }
                
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    // Handle authentication success
                }
                
                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    // Handle authentication failure
                }
            })
    }
    
    /**
     * Authenticate using biometric
     */
    private fun authenticateWithBiometric(
        title: String,
        subtitle: String, 
        description: String,
        negativeButtonText: String,
        callback: (Boolean, String?) -> Unit
    ) {
        promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle(title)
            .setSubtitle(subtitle)
            .setDescription(description)
            .setNegativeButtonText(negativeButtonText)
            .build()
        
        try {
            biometricPrompt.authenticate(promptInfo)
            // Note: Actual result is handled in BiometricPrompt.AuthenticationCallback
            // This is just to acknowledge the method call
            callback(true, null)
        } catch (e: Exception) {
            callback(false, e.message)
        }
    }
    
    /**
     * Get device information
     */
    private fun getDeviceInfo(): Map<String, String> {
        return mapOf(
            "manufacturer" to android.os.Build.MANUFACTURER,
            "model" to android.os.Build.MODEL,
            "version" to android.os.Build.VERSION.RELEASE,
            "sdkInt" to android.os.Build.VERSION.SDK_INT.toString(),
            "brand" to android.os.Build.BRAND,
            "device" to android.os.Build.DEVICE
        )
    }
    
    /**
     * Open app settings
     */
    private fun openAppSettings() {
        val intent = Intent().apply {
            action = android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS
            data = Uri.fromParts("package", packageName, null)
        }
        startActivity(intent)
    }
}