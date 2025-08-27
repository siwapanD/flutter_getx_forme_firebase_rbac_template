import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';

/// User model representing a user in the system
/// 
/// This model includes all user properties with RBAC (Role-Based Access Control)
/// support, including roles, permissions, and audit information.
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? phoneNumber;
  final bool emailVerified;
  final String role;
  final List<String> permissions;
  final Map<String, dynamic>? customClaims;
  final DateTime createdAt;
  final DateTime? lastSignInAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool isBlocked;
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? settings;
  
  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.phoneNumber,
    required this.emailVerified,
    required this.role,
    required this.permissions,
    this.customClaims,
    required this.createdAt,
    this.lastSignInAt,
    this.updatedAt,
    required this.isActive,
    this.isBlocked = false,
    this.profile,
    this.settings,
  });
  
  /// Create a copy of this user with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    bool? emailVerified,
    String? role,
    List<String>? permissions,
    Map<String, dynamic>? customClaims,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isBlocked,
    Map<String, dynamic>? profile,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      customClaims: customClaims ?? this.customClaims,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      profile: profile ?? this.profile,
      settings: settings ?? this.settings,
    );
  }
  
  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'role': role,
      'permissions': permissions,
      'customClaims': customClaims,
      'createdAt': createdAt.toIso8601String(),
      'lastSignInAt': lastSignInAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'isBlocked': isBlocked,
      'profile': profile,
      'settings': settings,
    };
  }
  
  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'role': role,
      'permissions': permissions,
      'customClaims': customClaims,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSignInAt': lastSignInAt != null ? Timestamp.fromDate(lastSignInAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'profile': profile,
      'settings': settings,
    };
  }
  
  /// Create from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      emailVerified: json['emailVerified'] as bool,
      role: json['role'] as String,
      permissions: List<String>.from(json['permissions'] as List),
      customClaims: json['customClaims'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInAt: json['lastSignInAt'] != null 
          ? DateTime.parse(json['lastSignInAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool,
      isBlocked: json['isBlocked'] as bool? ?? false,
      profile: json['profile'] as Map<String, dynamic>?,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }
  
  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      photoURL: data['photoURL'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      emailVerified: data['emailVerified'] as bool,
      role: data['role'] as String,
      permissions: List<String>.from(data['permissions'] as List),
      customClaims: data['customClaims'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastSignInAt: data['lastSignInAt'] != null 
          ? (data['lastSignInAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] as bool,
      isBlocked: data['isBlocked'] as bool? ?? false,
      profile: data['profile'] as Map<String, dynamic>?,
      settings: data['settings'] as Map<String, dynamic>?,
    );
  }
  
  /// Create an empty user model for new users
  factory UserModel.empty() {
    return UserModel(
      uid: '',
      email: '',
      displayName: '',
      emailVerified: false,
      role: AppConstants.roleGuest,
      permissions: AppConstants.getDefaultPermissions(AppConstants.roleGuest),
      createdAt: DateTime.now(),
      isActive: false,
    );
  }
  
  /// Create a new user model with default values
  factory UserModel.create({
    required String uid,
    required String email,
    required String displayName,
    String? photoURL,
    String? phoneNumber,
    bool emailVerified = false,
    String role = AppConstants.roleUser,
    Map<String, dynamic>? profile,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      phoneNumber: phoneNumber,
      emailVerified: emailVerified,
      role: role,
      permissions: AppConstants.getDefaultPermissions(role),
      createdAt: DateTime.now(),
      isActive: true,
      profile: profile,
      settings: settings,
    );
  }
  
  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }
  
  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> requiredPermissions) {
    return requiredPermissions.any((permission) => permissions.contains(permission));
  }
  
  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<String> requiredPermissions) {
    return requiredPermissions.every((permission) => permissions.contains(permission));
  }
  
  /// Check if user has a specific role
  bool hasRole(String requiredRole) {
    return role == requiredRole;
  }
  
  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> requiredRoles) {
    return requiredRoles.contains(role);
  }
  
  /// Check if user role has sufficient privilege level
  bool hasRolePrivilege(String requiredRole) {
    return AppConstants.hasRolePrivilege(role, requiredRole);
  }
  
  /// Check if user is admin (admin or super_admin)
  bool get isAdmin {
    return hasAnyRole([AppConstants.roleAdmin, AppConstants.roleSuperAdmin]);
  }
  
  /// Check if user is super admin
  bool get isSuperAdmin {
    return hasRole(AppConstants.roleSuperAdmin);
  }
  
  /// Check if user can manage other users
  bool get canManageUsers {
    return hasPermission(AppConstants.permissionManageUsers);
  }
  
  /// Check if user can manage roles
  bool get canManageRoles {
    return hasPermission(AppConstants.permissionManageRoles);
  }
  
  /// Check if user can view reports
  bool get canViewReports {
    return hasPermission(AppConstants.permissionViewReports);
  }
  
  /// Check if user can export data
  bool get canExportData {
    return hasPermission(AppConstants.permissionExportData);
  }
  
  /// Check if user account is fully set up
  bool get isSetupComplete {
    return displayName.isNotEmpty && 
           email.isNotEmpty && 
           emailVerified && 
           isActive;
  }
  
  /// Check if user needs to complete profile
  bool get needsProfileCompletion {
    return displayName.isEmpty || !emailVerified;
  }
  
  /// Get user's full name or display name
  String get fullName {
    if (profile != null) {
      final firstName = profile!['firstName'] as String?;
      final lastName = profile!['lastName'] as String?;
      
      if (firstName != null && lastName != null) {
        return '$firstName $lastName'.trim();
      }
    }
    
    return displayName.isNotEmpty ? displayName : email;
  }
  
  /// Get user's initials for avatar
  String get initials {
    final name = fullName;
    if (name.isEmpty) return '';
    
    final words = name.split(' ');
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    } else {
      return words[0][0].toUpperCase();
    }
  }
  
  /// Get profile value by key
  T? getProfileValue<T>(String key) {
    if (profile == null) return null;
    return profile![key] as T?;
  }
  
  /// Get setting value by key
  T? getSettingValue<T>(String key, {T? defaultValue}) {
    if (settings == null) return defaultValue;
    return settings![key] as T? ?? defaultValue;
  }
  
  /// Update profile data
  UserModel updateProfile(Map<String, dynamic> profileData) {
    final updatedProfile = Map<String, dynamic>.from(profile ?? {});
    updatedProfile.addAll(profileData);
    
    return copyWith(
      profile: updatedProfile,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Update settings data
  UserModel updateSettings(Map<String, dynamic> settingsData) {
    final updatedSettings = Map<String, dynamic>.from(settings ?? {});
    updatedSettings.addAll(settingsData);
    
    return copyWith(
      settings: updatedSettings,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Update last sign in time
  UserModel updateLastSignIn() {
    return copyWith(
      lastSignInAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Block user
  UserModel block() {
    return copyWith(
      isBlocked: true,
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Unblock user
  UserModel unblock() {
    return copyWith(
      isBlocked: false,
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Deactivate user
  UserModel deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Activate user
  UserModel activate() {
    return copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }
  
  @override
  String toString() {
    return 'UserModel{uid: $uid, email: $email, displayName: $displayName, role: $role}';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.uid == uid &&
        other.email == email &&
        other.displayName == displayName &&
        other.role == role;
  }
  
  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        role.hashCode;
  }
}