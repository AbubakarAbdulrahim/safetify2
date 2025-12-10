import 'dart:io' as java;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _loadCurrentUser();
      } else {
        _currentUser = null;
        _isInitialized = true; // Auth check complete (no user)
        notifyListeners();
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      _isLoading = false;
      _isInitialized = true; // Auth check complete (user loaded or failed)
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> updateProfileImage(java.File imageFile) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await _authService.uploadProfileImage(_currentUser!.id, imageFile);
      _currentUser = _currentUser!.copyWith(profileImage: imageUrl);
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
