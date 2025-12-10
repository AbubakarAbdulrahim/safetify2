import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import '../models/incident.dart';
import '../models/user_model.dart';
import '../models/alert_model.dart';
import '../models/community_update_model.dart';
import '../models/audit_log_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Incidents
  Stream<List<Incident>> getIncidents() {
    return _firestore
        .collection(AppConstants.incidentsCollection)
        .orderBy('createdAt', descending: true) // Changed from timestamp
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Incident.fromFirestore(doc)).toList());
  }

  Future<void> updateIncidentStatus(String id, String status) async {
    Map<String, dynamic> updates = {'status': status};
    
    // Sync with User App's verified/resolved booleans
    if (status == 'verified') {
      updates['verified'] = true;
    } else if (status == 'resolved') {
        updates['resolved'] = true;
        updates['verified'] = true; // Keep it verified if it's resolved
    } else if (status == 'rejected' || status == 'pending') {
      updates['verified'] = false;
      updates['resolved'] = false;
    }

    await _firestore
        .collection(AppConstants.incidentsCollection)
        .doc(id)
        .update(updates);
  }

  Future<void> deleteIncident(String id) async {
    await _firestore
        .collection(AppConstants.incidentsCollection)
        .doc(id)
        .delete();
  }

  // Users
  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        // Removed orderBy to ensure we get all users even if fields are missing
        // .orderBy('lastUpdated', descending: true) 
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Future<void> updateUserBanStatus(String id, bool isBanned) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(id)
        .update({'isBanned': isBanned});
  }

  Future<void> updateUserRole(String id, String role) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(id)
        .update({'role': role});
  }

  // Audit Logs
  Future<void> logAction(AuditLogModel log) async {
    await _firestore
        .collection(AppConstants.auditLogsCollection)
        .add(log.toMap());
  }

  Stream<List<AuditLogModel>> getAuditLogs() {
    return _firestore
        .collection(AppConstants.auditLogsCollection)
        .orderBy('timestamp', descending: true)
        .limit(50) // Limit to last 50 actions for performance
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditLogModel.fromFirestore(doc))
            .toList());
  }

  // Alerts
  Future<void> sendAlert(AlertModel alert) async {
    await _firestore
        .collection(AppConstants.alertsCollection)
        .add(alert.toMap());
  }
  
  Stream<List<AlertModel>> getAlerts() {
    return _firestore
        .collection(AppConstants.alertsCollection)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList());
  }

  // Community Updates
  Future<void> sendCommunityUpdate(CommunityUpdate update) async {
    await _firestore
        .collection(AppConstants.communityUpdatesCollection)
        .add(update.toMap());
  }

  Stream<List<CommunityUpdate>> getCommunityUpdates() {
    return _firestore
        .collection(AppConstants.communityUpdatesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CommunityUpdate.fromDoc(doc)).toList());
  }
}
