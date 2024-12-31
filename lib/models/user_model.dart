import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  // age 제거하고 birthDate 추가
  final String uid;
  final String email;
  final String? socialProvider;
  final String? socialId;
  final String phoneNumber;
  final String username;
  final String gender;
  final DateTime birthDate;  // age를 birthDate로 변경
  final String region;
  final String skinType;
  final List<String> skinConditions;
  final String profileImageUrl;
  final String icon;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> likedReviews;
  final List<String> favoriteProducts;
  final String role;
  final String grade;

  UserModel({
    required this.uid,
    required this.email,
    this.socialProvider,
    this.socialId,
    this.phoneNumber = '',
    required this.username,
    required this.gender,
    required this.birthDate,  // age를 birthDate로 변경
    required this.region,
    required this.skinType,
    this.skinConditions = const [],
    this.profileImageUrl = '',
    this.icon = '',
    required this.createdAt,
    required this.lastLoginAt,
    this.likedReviews = const [],
    this.favoriteProducts = const [],
    required this.role,
    this.grade = 'Bronze',
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'],
      socialProvider: data['socialProvider'],
      socialId: data['socialId'],
      phoneNumber: data['phoneNumber'] ?? '',
      username: data['username'],
      gender: data['gender'],
      birthDate: (data['birthDate'] as Timestamp).toDate(),  // age를 birthDate로 변경
      region: data['region'],
      skinType: data['skinType'],
      skinConditions: List<String>.from(data['skinConditions'] ?? []),
      profileImageUrl: data['profileImageUrl'] ?? '',
      icon: data['icon'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      likedReviews: List<String>.from(data['likedReviews'] ?? []),
      favoriteProducts: List<String>.from(data['favoriteProducts'] ?? []),
      role: data['role'] ?? 'user',
      grade: data['grade'] ?? 'Bronze',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'socialProvider': socialProvider,
      'socialId': socialId,
      'phoneNumber': phoneNumber,
      'username': username,
      'gender': gender,
      'birthDate': Timestamp.fromDate(birthDate),  // age를 birthDate로 변경
      'region': region,
      'skinType': skinType,
      'skinConditions': skinConditions,
      'profileImageUrl': profileImageUrl,
      'icon': icon,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'likedReviews': likedReviews,
      'favoriteProducts': favoriteProducts,
      'role': role,
      'grade': grade,
    };
  }

  factory UserModel.fromEmailSignup({
    required String uid,
    required String email,
    required String username,
    required String gender,
    required DateTime birthDate,  // age를 birthDate로 변경
    required String region,
    required String skinType,
    required List<String> skinConditions,
    required String icon,
    required DateTime createdAt,
    required DateTime lastLoginAt,
    required String profileImageUrl,
    required String role,
    required String grade,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      socialProvider: 'email',
      username: username,
      gender: gender,
      birthDate: birthDate,  // age를 birthDate로 변경
      region: region,
      skinType: skinType,
      skinConditions: skinConditions,
      icon: icon,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      role: 'user',
      grade: 'Bronze',
    );
  }

  factory UserModel.fromFacebookAuth(UserCredential credential) {
    final user = credential.user!;
    final additionalUserInfo = credential.additionalUserInfo!;
    final profile = additionalUserInfo.profile ?? {};

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      socialProvider: 'facebook',
      socialId: profile['id']?.toString(),
      username: user.displayName ?? '',
      phoneNumber: user.phoneNumber ?? '',
      gender: '',
      birthDate: DateTime.now(),  // 기본값 설정, 추가 정보 필요
      region: '',
      skinType: '',
      profileImageUrl: user.photoURL ?? '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      role: 'user',
    );
  }

  factory UserModel.fromGoogleAuth(UserCredential credential) {
    final user = credential.user!;

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      socialProvider: 'google',
      socialId: user.uid,
      username: user.displayName ?? '',
      phoneNumber: user.phoneNumber ?? '',
      gender: '',
      birthDate: DateTime.now(),  // 기본값 설정, 추가 정보 필요
      region: '',
      skinType: '',
      profileImageUrl: user.photoURL ?? '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      role: 'user',
    );
  }

  UserModel copyWith({
    String? gender,
    DateTime? birthDate,  // age를 birthDate로 변경
    String? region,
    String? skinType,
    List<String>? skinConditions,
    String? username,
    String? icon,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      socialProvider: socialProvider,
      socialId: socialId,
      phoneNumber: phoneNumber,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,  // age를 birthDate로 변경
      region: region ?? this.region,
      skinType: skinType ?? this.skinType,
      skinConditions: skinConditions ?? this.skinConditions,
      profileImageUrl: profileImageUrl,
      icon: icon ?? this.icon,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      likedReviews: likedReviews,
      favoriteProducts: favoriteProducts,
      role: role,
      grade: grade,
    );
  }
}