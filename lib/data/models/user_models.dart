import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModels {
  final String uid;
  final String username;
  final String fullname;
  final String email;
  final String phoneNumber;
  final Timestamp createdAt;
  final Timestamp lastSeen;
  final bool isOnline;
  final String? fcmToken;
  final List<String> blockedUsers;

  UserModels({
    required this.uid,
    required this.username,
    required this.fullname,
    required this.email,
    required this.phoneNumber,
    Timestamp? createdAt,
    Timestamp? lastSeen,
    this.isOnline = false,
    this.fcmToken,
    this.blockedUsers = const [],
  }) : lastSeen = lastSeen ?? Timestamp.now(),
       createdAt = createdAt ?? Timestamp.now();

  UserModels copyWith({
    String? uid,
    String? username,
    String? fullName,
    String? email,
    String? phoneNumber,
    bool? isOnline,
    Timestamp? lastSeen,
    Timestamp? createdAt,
    String? fcmToken,
    List<String>? blockedUsers,
  }) {
    return UserModels(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      fullname: fullName ?? this.fullname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  factory UserModels.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModels(
      uid: doc.id,
      username: data['username'] ?? "",
      fullname: data['fullName'] ?? "",
      email: data['email'] ?? "",
      phoneNumber: data['phoneNumber'] ?? "",
      fcmToken: data['fcmToken'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      lastSeen: data['lastSeen'] ?? Timestamp.now(),
      blockedUsers: List<String>.from(data['blockedUsers']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'fullname': fullname,
      'phoneNumber': phoneNumber,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
      'fcmTokens': fcmToken,
      'email': email,
      'blockedUsers': blockedUsers,
    };
  }
}
