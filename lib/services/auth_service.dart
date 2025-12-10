
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc);
      }
    }
    return null;
  }

  Future<void> signIn(String email, String password) async {
    // Login
    UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Check if this user is admin
    DocumentSnapshot doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(cred.user!.uid)
        .get();

    if (!doc.exists || doc['role'] != 'admin') {
      // Not an admin → deny access and logout
      await _auth.signOut();
      throw Exception("Access denied. You are not an admin.");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('profile_image.jpg');

      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'profileImage': url});

      return url;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}

