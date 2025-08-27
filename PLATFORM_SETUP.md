# Platform Configuration Setup Guide

This document provides a comprehensive guide for setting up iOS and Android platform configurations for the Flutter GetX Forme Firebase RBAC Template.

## Overview

The platform configuration files have been created to support:
- Firebase integration (Authentication, Firestore, Storage, Messaging)
- Google Sign-In and Apple Sign-In
- Biometric authentication
- Camera and photo library access
- Push notifications
- Deep linking and universal links
- Multi-environment support (development, staging, production)

## iOS Configuration

### Required Setup Steps

1. **Firebase Configuration**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create or select your Firebase project
   - Add an iOS app with your bundle identifier
   - Download `GoogleService-Info.plist` and replace the template file in `ios/Runner/`
   - Update URL schemes in `Info.plist` with your `REVERSED_CLIENT_ID` from GoogleService-Info.plist

2. **Bundle Identifier Setup**
   - Update `PRODUCT_BUNDLE_IDENTIFIER` in Xcode project settings
   - Recommended format: `com.yourcompany.yourapp` (production), `com.yourcompany.yourapp.dev` (development)

3. **Apple Developer Account Setup**
   - Configure signing & capabilities in Xcode
   - Enable Apple Sign In capability
   - Configure associated domains for universal links
   - Set up push notification certificates

4. **Deep Linking Configuration**
   - Update URL schemes in `Info.plist` for your app's deep links
   - Configure associated domains in entitlements files
   - Update domain URLs to match your actual domains

5. **Permissions Configuration**
   - Review and update permission descriptions in `Info.plist`
   - Ensure they match your app's actual functionality

### Files to Configure

- `ios/Runner/GoogleService-Info.plist` - Replace with actual Firebase configuration
- `ios/Runner/Info.plist` - Update Firebase App ID, URL schemes, and domain associations
- `ios/Runner/Runner-Debug.entitlements` - Update associated domains
- `ios/Runner/Runner-Release.entitlements` - Update production domains

## Android Configuration

### Required Setup Steps

1. **Firebase Configuration**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Add an Android app with your package name
   - Download `google-services.json` and replace the template file in `android/app/`
   - Add SHA-1 fingerprint for Google Sign-In

2. **Package Name Setup**
   - Update `applicationId` in `android/app/build.gradle`
   - Update `namespace` in `android/app/build.gradle`
   - Update package name in `MainActivity.kt` and `FirebaseMessagingService.kt`
   - Update package directories to match your package name

3. **Signing Configuration**
   - Create release keystore for production builds
   - Update signing configuration in `android/app/build.gradle`
   - Configure `local.properties` with keystore information

4. **Deep Linking Configuration**
   - Update URL schemes and domains in `AndroidManifest.xml`
   - Configure app links for your actual domains

5. **Local Properties Setup**
   - Copy `android/local.properties.template` to `android/local.properties`
   - Update Flutter SDK path
   - Configure signing properties for release builds

### Files to Configure

- `android/app/google-services.json` - Replace with actual Firebase configuration
- `android/app/build.gradle` - Update package name and signing configuration
- `android/app/src/main/AndroidManifest.xml` - Update package references and domains
- `android/local.properties` - Configure local development settings
- MainActivity and FirebaseMessagingService - Update package declarations

## Multi-Environment Configuration

The configuration supports multiple environments:

### Development Environment
- Bundle ID/Package: `com.yourcompany.yourapp.dev`
- Firebase Project: `your-app-dev`
- App Name: "Your App (Dev)"

### Staging Environment
- Bundle ID/Package: `com.yourcompany.yourapp.staging`
- Firebase Project: `your-app-staging`
- App Name: "Your App (Staging)"

### Production Environment
- Bundle ID/Package: `com.yourcompany.yourapp`
- Firebase Project: `your-app-prod`
- App Name: "Your App"

### Environment Setup

1. Create separate Firebase projects for each environment
2. Download separate configuration files:
   - `GoogleService-Info-dev.plist`, `GoogleService-Info-staging.plist`, `GoogleService-Info-prod.plist`
   - `google-services-dev.json`, `google-services-staging.json`, `google-services-prod.json`
3. Use build scripts to copy the appropriate configuration file based on the build environment

## Security Considerations

### iOS Security
- Certificate pinning configured in network settings
- Keychain access groups configured for secure storage
- App Transport Security configured with Firebase exceptions

### Android Security
- Network security configuration with certificate pinning options
- ProGuard rules for code obfuscation in release builds
- Permissions properly scoped and documented

## Testing Configuration

1. **Development Testing**
   ```bash
   # iOS
   flutter run -t lib/main.dart --dart-define=ENVIRONMENT=development

   # Android
   flutter run -t lib/main.dart --dart-define=ENVIRONMENT=development --flavor development
   ```

2. **Production Testing**
   ```bash
   # iOS
   flutter build ios --dart-define=ENVIRONMENT=production

   # Android
   flutter build apk --dart-define=ENVIRONMENT=production --flavor production
   ```

## Troubleshooting

### Common Issues

1. **Firebase not initializing**
   - Verify GoogleService-Info.plist/google-services.json are properly configured
   - Check bundle ID/package name matches Firebase configuration

2. **Google Sign-In not working**
   - Verify REVERSED_CLIENT_ID is correctly set in iOS URL schemes
   - Ensure SHA-1 fingerprint is added to Firebase project for Android

3. **Apple Sign-In not working**
   - Verify Apple Sign-In capability is enabled in Xcode
   - Ensure Apple Developer account is properly configured

4. **Push notifications not working**
   - Verify FCM configuration in Firebase Console
   - Check notification permissions are granted
   - Ensure APNs certificates are configured for iOS

5. **Deep linking not working**
   - Verify URL schemes are properly configured
   - Check associated domains are set up correctly
   - Ensure deep link handling is implemented in the app

## Build Scripts

Consider creating build scripts for different environments:

```bash
# Development build
./scripts/build-dev.sh

# Staging build  
./scripts/build-staging.sh

# Production build
./scripts/build-prod.sh
```

These scripts should:
1. Copy the appropriate configuration files
2. Set environment variables
3. Build with the correct flavor/configuration

## Next Steps

1. Replace all TODO comments in configuration files with actual values
2. Set up Firebase projects for each environment
3. Configure Apple Developer account and certificates
4. Create release signing keys for Android
5. Test the configuration with actual builds
6. Set up CI/CD pipelines with environment-specific builds

For more information, refer to the official documentation:
- [Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [iOS App Distribution](https://docs.flutter.dev/deployment/ios)
- [Android App Distribution](https://docs.flutter.dev/deployment/android)