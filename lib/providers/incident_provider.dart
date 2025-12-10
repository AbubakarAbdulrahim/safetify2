import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/incident.dart';
import '../models/audit_log_model.dart';

class IncidentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Incident> _incidents = [];
  bool _isLoading = false;
  String _filterStatus = 'All';

  List<Incident> get incidents => _filterStatus == 'All'
      ? _incidents
      : _incidents.where((i) => i.status == _filterStatus.toLowerCase()).toList();
  
  bool get isLoading => _isLoading;
  String get filterStatus => _filterStatus;

  IncidentProvider() {
    _listenToIncidents();
  }

  Future<void> refreshIncidents() async {
    _listenToIncidents();
  }

  void _listenToIncidents() {
    _isLoading = true;
    notifyListeners();
    _firestoreService.getIncidents().listen((incidents) {
      _incidents = incidents;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching incidents: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }


  Future<void> updateStatus(String id, String status, String adminId, String adminName) async {
    await _firestoreService.updateIncidentStatus(id, status);
    await _firestoreService.logAction(AuditLogModel(
      id: '', // Firestore will generate ID
      adminId: adminId,
      adminName: adminName,
      action: 'UPDATE_INCIDENT_STATUS',
      targetId: id,
      details: 'Status changed to $status',
      timestamp: DateTime.now(),
    ));
  }

  Future<void> deleteIncident(String id, String adminId, String adminName) async {
    await _firestoreService.deleteIncident(id);
    await _firestoreService.logAction(AuditLogModel(
      id: '',
      adminId: adminId,
      adminName: adminName,
      action: 'DELETE_INCIDENT',
      targetId: id,
      details: 'Incident deleted',
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}
