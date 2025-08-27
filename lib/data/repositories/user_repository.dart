import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/firebase_provider.dart';
import '../models/user_model.dart';
import '../../core/utils/result.dart';
import '../../core/constants/app_constants.dart';

/// User repository that handles user data operations with Firestore
/// 
/// This repository manages user data operations including CRUD operations,
/// role management, and user search functionality.
class UserRepository {
  final FirebaseProvider _firebaseProvider = Get.find<FirebaseProvider>();
  
  static const String _usersCollection = 'users';
  static const String _rolesCollection = 'roles';
  static const String _permissionsCollection = 'permissions';
  
  /// Get Firestore instance
  FirebaseFirestore get _firestore => _firebaseProvider.firestore;
  
  /// Create a new user document
  Future<VoidResult> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(user.toFirestore());
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to create user: $e', stackTrace);
    }
  }
  
  /// Get user by UID
  Future<Result<UserModel?>> getUserById(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return Result.success(UserModel.fromFirestore(doc));
      }
      
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure('Failed to get user: $e', stackTrace);
    }
  }
  
  /// Get user by email
  Future<Result<UserModel?>> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (query.docs.isNotEmpty) {
        return Result.success(UserModel.fromFirestore(query.docs.first));
      }
      
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure('Failed to get user by email: $e', stackTrace);
    }
  }
  
  /// Update user data
  Future<VoidResult> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .update(updatedUser.toFirestore());
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to update user: $e', stackTrace);
    }
  }
  
  /// Update user profile
  Future<VoidResult> updateUserProfile(
    String uid,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'profile': profileData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to update user profile: $e', stackTrace);
    }
  }
  
  /// Update user settings
  Future<VoidResult> updateUserSettings(
    String uid,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'settings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to update user settings: $e', stackTrace);
    }
  }
  
  /// Update user role
  Future<VoidResult> updateUserRole(String uid, String role) async {
    try {
      // Validate role
      if (!AppConstants.allRoles.contains(role)) {
        return VoidResults.failure('Invalid role: $role');
      }
      
      final permissions = AppConstants.getDefaultPermissions(role);
      
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'role': role,
        'permissions': permissions,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to update user role: $e', stackTrace);
    }
  }
  
  /// Update user permissions
  Future<VoidResult> updateUserPermissions(
    String uid,
    List<String> permissions,
  ) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'permissions': permissions,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to update user permissions: $e', stackTrace);
    }
  }
  
  /// Block user
  Future<VoidResult> blockUser(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'isBlocked': true,
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to block user: $e', stackTrace);
    }
  }
  
  /// Unblock user
  Future<VoidResult> unblockUser(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'isBlocked': false,
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to unblock user: $e', stackTrace);
    }
  }
  
  /// Deactivate user
  Future<VoidResult> deactivateUser(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to deactivate user: $e', stackTrace);
    }
  }
  
  /// Activate user
  Future<VoidResult> activateUser(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to activate user: $e', stackTrace);
    }
  }
  
  /// Delete user (soft delete)
  Future<VoidResult> deleteUser(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'isActive': false,
        'isBlocked': true,
        'updatedAt': FieldValue.serverTimestamp(),
        'deletedAt': FieldValue.serverTimestamp(),
      });
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to delete user: $e', stackTrace);
    }
  }
  
  /// Get all users with pagination
  Future<Result<List<UserModel>>> getUsers({
    int limit = AppConstants.defaultPageSize,
    DocumentSnapshot? startAfter,
    String? orderBy = 'createdAt',
    bool descending = true,
  }) async {
    try {
      Query query = _firestore
          .collection(_usersCollection)
          .orderBy(orderBy!, descending: descending)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      
      return Result.success(users);
    } catch (e, stackTrace) {
      return Result.failure('Failed to get users: $e', stackTrace);
    }
  }
  
  /// Get users by role
  Future<Result<List<UserModel>>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: role)
          .where('isActive', isEqualTo: true)
          .orderBy('displayName')
          .get();
      
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      
      return Result.success(users);
    } catch (e, stackTrace) {
      return Result.failure('Failed to get users by role: $e', stackTrace);
    }
  }
  
  /// Search users by name or email
  Future<Result<List<UserModel>>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    try {
      if (query.isEmpty) {
        return const Result.success([]);
      }
      
      final lowercaseQuery = query.toLowerCase();
      
      // Search by display name
      final nameQuery = await _firestore
          .collection(_usersCollection)
          .where('displayName', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('displayName', isLessThan: '${lowercaseQuery}z')
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();
      
      // Search by email
      final emailQuery = await _firestore
          .collection(_usersCollection)
          .where('email', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('email', isLessThan: '${lowercaseQuery}z')
          .where('isActive', isEqualTo: true)
          .limit(limit)
          .get();
      
      // Combine results and remove duplicates
      final allDocs = [...nameQuery.docs, ...emailQuery.docs];
      final uniqueDocs = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
      
      for (final doc in allDocs) {
        uniqueDocs[doc.id] = doc;
      }
      
      final users = uniqueDocs.values
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      
      // Sort by relevance (exact matches first)
      users.sort((a, b) {
        final aNameMatch = a.displayName.toLowerCase().startsWith(lowercaseQuery);
        final aEmailMatch = a.email.toLowerCase().startsWith(lowercaseQuery);
        final bNameMatch = b.displayName.toLowerCase().startsWith(lowercaseQuery);
        final bEmailMatch = b.email.toLowerCase().startsWith(lowercaseQuery);
        
        if ((aNameMatch || aEmailMatch) && !(bNameMatch || bEmailMatch)) {
          return -1;
        } else if (!(aNameMatch || aEmailMatch) && (bNameMatch || bEmailMatch)) {
          return 1;
        }
        
        return a.displayName.compareTo(b.displayName);
      });
      
      return Result.success(users.take(limit).toList());
    } catch (e, stackTrace) {
      return Result.failure('Failed to search users: $e', stackTrace);
    }
  }
  
  /// Get active users count
  Future<Result<int>> getActiveUsersCount() async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      
      return Result.success(snapshot.count ?? 0);
    } catch (e, stackTrace) {
      return Result.failure('Failed to get active users count: $e', stackTrace);
    }
  }
  
  /// Get users count by role
  Future<Result<Map<String, int>>> getUsersCountByRole() async {
    try {
      final roleCounts = <String, int>{};
      
      for (final role in AppConstants.allRoles) {
        final snapshot = await _firestore
            .collection(_usersCollection)
            .where('role', isEqualTo: role)
            .where('isActive', isEqualTo: true)
            .count()
            .get();
        
        roleCounts[role] = snapshot.count ?? 0;
      }
      
      return Result.success(roleCounts);
    } catch (e, stackTrace) {
      return Result.failure('Failed to get users count by role: $e', stackTrace);
    }
  }
  
  /// Get recently registered users
  Future<Result<List<UserModel>>> getRecentUsers({
    int limit = 10,
    int daysBack = 7,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
      
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoffDate))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      
      return Result.success(users);
    } catch (e, stackTrace) {
      return Result.failure('Failed to get recent users: $e', stackTrace);
    }
  }
  
  /// Listen to user changes
  Stream<UserModel?> listenToUser(String uid) {
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      }
      return null;
    });
  }
  
  /// Listen to users list changes
  Stream<List<UserModel>> listenToUsers({
    int limit = AppConstants.defaultPageSize,
    String? role,
    bool activeOnly = true,
  }) {
    Query query = _firestore
        .collection(_usersCollection);
    
    if (role != null) {
      query = query.where('role', isEqualTo: role);
    }
    
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }
    
    query = query
        .orderBy('displayName')
        .limit(limit);
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    });
  }
  
  /// Batch update users
  Future<VoidResult> batchUpdateUsers(
    List<String> userIds,
    Map<String, dynamic> updates,
  ) async {
    try {
      final batch = _firestore.batch();
      
      for (final uid in userIds) {
        final userRef = _firestore.collection(_usersCollection).doc(uid);
        batch.update(userRef, {
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to batch update users: $e', stackTrace);
    }
  }
  
  /// Export users data
  Future<Result<List<Map<String, dynamic>>>> exportUsers({
    String? role,
    bool activeOnly = true,
  }) async {
    try {
      Query query = _firestore.collection(_usersCollection);
      
      if (role != null) {
        query = query.where('role', isEqualTo: role);
      }
      
      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }
      
      final snapshot = await query.get();
      
      final usersData = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Remove sensitive data
        data.remove('customClaims');
        return data;
      }).toList();
      
      return Result.success(usersData);
    } catch (e, stackTrace) {
      return Result.failure('Failed to export users: $e', stackTrace);
    }
  }
  
  /// Check if email is already in use
  Future<Result<bool>> isEmailInUse(String email) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();
      
      return Result.success(snapshot.docs.isNotEmpty);
    } catch (e, stackTrace) {
      return Result.failure('Failed to check email availability: $e', stackTrace);
    }
  }
  
  /// Update user last sign in
  Future<VoidResult> updateLastSignIn(String uid) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update({
        'lastSignInAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to update last sign in: $e', stackTrace);
    }
  }
}