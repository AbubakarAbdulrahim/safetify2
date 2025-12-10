import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/audit_log_model.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _users = [];
  bool _isLoading = false;

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;

  UserProvider() {
    _listenToUsers();
  }

  void _listenToUsers() {
    _isLoading = true;
    notifyListeners();
    _firestoreService.getUsers().listen((users) {
      print('Fetched ${users.length} users');
      _users = users;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching users: $error');
      _isLoading = false;
      notifyListeners();
    });
  }


  Future<void> toggleBanStatus(String id, bool currentStatus, String adminId, String adminName) async {
    final newStatus = !currentStatus;
    await _firestoreService.updateUserBanStatus(id, newStatus);
    await _firestoreService.logAction(AuditLogModel(
      id: '',
      adminId: adminId,
      adminName: adminName,
      action: newStatus ? 'BAN_USER' : 'UNBAN_USER',
      targetId: id,
      details: 'User ${newStatus ? 'banned' : 'unbanned'}',
      timestamp: DateTime.now(),
    ));
  }

  Future<void> updateUserRole(String id, String role, String adminId, String adminName) async {
    await _firestoreService.updateUserRole(id, role);
    await _firestoreService.logAction(AuditLogModel(
      id: '',
      adminId: adminId,
      adminName: adminName,
      action: 'UPDATE_USER_ROLE',
      targetId: id,
      details: 'Role changed to $role',
      timestamp: DateTime.now(),
    ));
  }
}
