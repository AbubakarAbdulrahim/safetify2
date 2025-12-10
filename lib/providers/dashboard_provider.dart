import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/audit_log_model.dart';

class DashboardProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  Stream<List<AuditLogModel>> get auditLogs => _firestoreService.getAuditLogs();

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
