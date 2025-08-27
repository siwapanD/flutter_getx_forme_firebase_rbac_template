import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/user_model.dart';
import '../../core/utils/result.dart';
import '../../core/constants/app_constants.dart';

/// Authentication provider that handles Firebase Auth operations
/// 
/// This provider abstracts Firebase Authentication operations and provides
/// a clean interface for authentication-related functionality.
class AuthProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;
  
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  /// Sign in with email and password
  Future<Result<UserModel>> signInWithEmail(
    String email, 
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return const Result.failure('Sign in failed: No user returned');
      }
      
      final userModel = await _getUserModel(credential.user!);
      return Result.success(userModel);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Result.failure(_mapFirebaseError(e), stackTrace);
    } catch (e, stackTrace) {
      return Result.failure('Sign in failed: $e', stackTrace);
    }
  }
  
  /// Sign up with email and password
  Future<Result<UserModel>> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return const Result.failure('Sign up failed: No user returned');
      }
      
      // Update display name
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();
      
      final userModel = await _getUserModel(credential.user!);
      return Result.success(userModel);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Result.failure(_mapFirebaseError(e), stackTrace);
    } catch (e, stackTrace) {
      return Result.failure('Sign up failed: $e', stackTrace);
    }
  }
  
  /// Sign in with Google
  Future<Result<UserModel>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Result.failure('Google sign in cancelled');
      }
      
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        return const Result.failure('Google sign in failed: No user returned');
      }
      
      final userModel = await _getUserModel(userCredential.user!);
      return Result.success(userModel);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Result.failure(_mapFirebaseError(e), stackTrace);
    } catch (e, stackTrace) {
      return Result.failure('Google sign in failed: $e', stackTrace);
    }
  }
  
  /// Sign in with Apple
  Future<Result<UserModel>> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      
      if (userCredential.user == null) {
        return const Result.failure('Apple sign in failed: No user returned');
      }
      
      final userModel = await _getUserModel(userCredential.user!);
      return Result.success(userModel);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Result.failure(_mapFirebaseError(e), stackTrace);
    } catch (e, stackTrace) {
      return Result.failure('Apple sign in failed: $e', stackTrace);
    }
  }
  
  /// Send password reset email
  Future<VoidResult> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return VoidResults.success();
    } on FirebaseAuthException catch (e, stackTrace) {
      return VoidResults.failure(_mapFirebaseError(e), stackTrace);
    } catch (e, stackTrace) {
      return VoidResults.failure('Password reset failed: $e', stackTrace);
    }
  }
  
  /// Send email verification
  Future<VoidResult> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return VoidResults.failure('No user signed in');
      }
      
      await user.sendEmailVerification();
      return VoidResults.success();
    } on FirebaseAuthException catch (e, stackTrace) {
      return VoidResults.failure(_mapFirebaseError(e), stackTrace);
    } catch (e, stackTrace) {
      return VoidResults.failure('Email verification failed: $e', stackTrace);
    }
  }
  
  /// Update user profile
  Future<Result<UserModel>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Result.failure('No user signed in');
      }
      
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
      await user.reload();
      
      final userModel = await _getUserModel(user);
      return Result.success(userModel);
    } on FirebaseAuthException catch (e, stackTrace) {
      return Result.failure(_mapFirebaseError(e), stackTrace);
    } catch (e, stackTrace) {
      return Result.failure('Profile update failed: $e', stackTrace);
    }
  }
  
  /// Change password
  Future<VoidResult> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return VoidResults.failure('No user signed in');
      }
      
      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      
      return VoidResults.success();
    } on FirebaseAuthException catch (e, stackTrace) {
      return VoidResults.failure(_mapFirebaseError(e), stackTrace);
    } catch (e, stackTrace) {
      return VoidResults.failure('Password change failed: $e', stackTrace);
    }
  }
  
  /// Delete user account
  Future<VoidResult> deleteAccount(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return VoidResults.failure('No user signed in');
      }
      
      // Re-authenticate user before deleting account
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);
      await user.delete();
      
      return VoidResults.success();
    } on FirebaseAuthException catch (e, stackTrace) {
      return VoidResults.failure(_mapFirebaseError(e), stackTrace);
    } catch (e, stackTrace) {
      return VoidResults.failure('Account deletion failed: $e', stackTrace);
    }
  }
  
  /// Sign out
  Future<VoidResult> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Sign out failed: $e', stackTrace);
    }
  }
  
  /// Get current user model
  Future<Result<UserModel>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Result.failure('No user signed in');
      }
      
      final userModel = await _getUserModel(user);
      return Result.success(userModel);
    } catch (e, stackTrace) {
      return Result.failure('Failed to get current user: $e', stackTrace);
    }
  }
  
  /// Reload current user
  Future<VoidResult> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return VoidResults.failure('No user signed in');
      }
      
      await user.reload();
      return VoidResults.success();
    } catch (e, stackTrace) {
      return VoidResults.failure('Failed to reload user: $e', stackTrace);
    }
  }
  
  /// Helper method to create UserModel from Firebase User
  Future<UserModel> _getUserModel(User user) async {
    await user.reload(); // Ensure we have the latest user data
    
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      phoneNumber: user.phoneNumber,
      role: AppConstants.roleUser, // Default role, should be fetched from Firestore
      permissions: AppConstants.getDefaultPermissions(AppConstants.roleUser),
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastSignInAt: user.metadata.lastSignInTime,
      isActive: true,
    );
  }
  
  /// Map Firebase Auth errors to user-friendly messages
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}