import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Incident {
  final String id;
  final String category;
  final String description;
  final double lat;
  final double lon;
  final String locationName;
  final String photoUrl;
  final String userId;
  final bool verified;
  final DateTime createdAt;
  final int upvotes;
  final int downvotes;
  final Map<String, dynamic> userVotes;

  // Admin App specific fields (optional/derived)
  final String? _status; 

  Incident({
    required this.id,
    required this.category,
    required this.description,
    required this.lat,
    required this.lon,
    required this.locationName,
    required this.photoUrl,
    required this.userId,
    this.verified = false,
    required this.createdAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.userVotes = const {},
    String? status,
  }) : _status = status;

  // Getters for Admin UI Compatibility
  String get title => category; // Use category as title
  LatLng get location => LatLng(lat, lon);
  String get reporterId => userId;
  DateTime get timestamp => createdAt;
  String? get imageUrl => photoUrl.isNotEmpty ? photoUrl : null;
  int get verificationCount => upvotes;
  
  // Map boolean verified to status string, or use stored status if available
  String get status {
    if (_status != null) return _status!;
    return verified ? 'verified' : 'pending';
  }

  factory Incident.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Incident(
      id: doc.id,
      category: data['category'] ?? 'General',
      description: data['description'] ?? '',
      lat: (data['lat'] ?? 0).toDouble(),
      lon: (data['lon'] ?? 0).toDouble(),
      locationName: data['locationName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      userId: data['userId'] ?? '',
      verified: data['verified'] ?? false,
      createdAt: _parseDateTime(data['createdAt']),
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      userVotes: data['userVotes'] ?? {},
      status: data['status'], // Try to read explicit status if Admin added it
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'description': description,
      'lat': lat,
      'lon': lon,
      'locationName': locationName,
      'photoUrl': photoUrl,
      'userId': userId,
      'verified': verified,
      'createdAt': Timestamp.fromDate(createdAt),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'userVotes': userVotes,
      'status': _status, // Write back status if we have it
    };
  }
}
