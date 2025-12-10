import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class AlertModel {
  final String id;
  final String title;
  final String message;
  final String type; // manual, location-based, targeted
  final DateTime sentAt;
  final String? targetArea;
  final LatLng? targetLocation;
  final double? radius;

  AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.sentAt,
    this.targetArea,
    this.targetLocation,
    this.radius,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    GeoPoint? geoPoint = data['targetLocation'];
    return AlertModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'manual',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetArea: data['targetArea'],
      targetLocation: geoPoint != null ? LatLng(geoPoint.latitude, geoPoint.longitude) : null,
      radius: (data['radius'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'sentAt': Timestamp.fromDate(sentAt),
      'targetArea': targetArea,
      'targetLocation': targetLocation != null ? GeoPoint(targetLocation!.latitude, targetLocation!.longitude) : null,
      'radius': radius,
    };
  }
}
