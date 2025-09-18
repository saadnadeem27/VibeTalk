import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flash_chat/app/models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    // Remove automatic navigation - handle in main.dart instead
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(displayName);

        // Create user document in Firestore
        await createUserDocument(credential.user!, displayName);

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Sign Up Error',
        _getErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Sign In Error',
        _getErrorMessage(e.code),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Update user online status
      if (_auth.currentUser != null) {
        await updateUserOnlineStatus(false);
      }
      await _auth.signOut();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> createUserDocument(User user, String displayName) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      displayName: displayName,
      photoURL: user.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOnline: true,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
  }

  Future<void> getCurrentUser() async {
    if (_auth.currentUser != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (doc.exists) {
        currentUser.value = UserModel.fromFirestore(doc);
        // Update online status when user opens app
        await updateUserOnlineStatus(true);
      }
    }
  }

  Future<void> updateUserOnlineStatus(bool isOnline) async {
    if (_auth.currentUser != null) {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'isOnline': isOnline,
        'lastSeen': isOnline ? null : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? status,
    bool? showLastSeen,
    bool? readReceipts,
  }) async {
    if (_auth.currentUser != null) {
      Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) {
        updates['displayName'] = displayName;
        await _auth.currentUser!.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        updates['photoURL'] = photoURL;
        await _auth.currentUser!.updatePhotoURL(photoURL);
      }

      if (status != null) updates['status'] = status;
      if (showLastSeen != null) updates['showLastSeen'] = showLastSeen;
      if (readReceipts != null) updates['readReceipts'] = readReceipts;

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(updates);

      // Refresh current user data
      await getCurrentUser();
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'An error occurred';
    }
  }
}
