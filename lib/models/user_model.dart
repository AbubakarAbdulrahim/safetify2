import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final double? lat;
  final double? lon;
  final String? fcmToken;
  final String? profileImage;
  final DateTime? lastUpdated;
  
  // Admin specific fields
  final String role;
  final bool isBanned;
  final DateTime createdAt; // Mapped to lastUpdated or now for UI compatibility

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    this.lat,
    this.lon,
    this.fcmToken,
    this.profileImage,
    this.lastUpdated,
    required this.role,
    this.isBanned = false,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? data['phone'] ?? '',
      lat: (data['lat'] as num?)?.toDouble(),
      lon: (data['lon'] as num?)?.toDouble(),
      fcmToken: data['fcmToken'],
      profileImage: data['profileImage'],
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
      // Admin fields - read if exist, else default
      role: data['role'] ?? 'user',
      isBanned: data['isBanned'] ?? false,
      createdAt: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'lat': lat,
      'lon': lon,
      'fcmToken': fcmToken,
      'profileImage': profileImage,
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
      'role': role,
      'isBanned': isBanned,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    double? lat,
    double? lon,
    String? fcmToken,
    String? profileImage,
    DateTime? lastUpdated,
    String? role,
    bool? isBanned,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      fcmToken: fcmToken ?? this.fcmToken,
      profileImage: profileImage ?? this.profileImage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      role: role ?? this.role,
      isBanned: isBanned ?? this.isBanned,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
