import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 사용자 모델 - Firestore와 연동되는 데이터 클래스
class UserModel {
  final String uid; // Firebase Auth UID 추가
  final String email;
  final String? socialProvider; // 소셜 로그인 제공자 추가 (google, facebook, null)
  final String? socialId; // 소셜 계정 ID 추가
  final String phoneNumber; // 전화번호
  final String username; // 사용자 이름 (닉네임)
  final String gender; // 성별 (남성/여성/기타)
  final int age; // 나이
  final String region; // 지역 (베트남/한국)
  final String skinType; // 피부 타입 (지성/건성/복합성/민감성/정상)
  final List<String> skinConditions; // 피부 상태 (여드름/홍조/주름/잡티 등 다중 선택 가능)
  final String profileImageUrl; // 프로필 이미지 URL
  final String icon; // 사용자 아이콘 또는 이모티콘
  final DateTime createdAt; // 계정 생성 시간
  final DateTime lastLoginAt; // 최근 접속 시간
  final List<String> likedReviews; // 사용자가 좋아요한 리뷰 ID 목록
  final List<String> favoriteProducts; // 즐겨찾기한 상품 ID 목록
  final String role; // 사용자 역할 (예: 'user', 'admin', 'moderator')
  final String grade; // 사용자 등급 (예: 'Bronze', 'Silver', 'Gold', 'Platinum')

  UserModel({
    required this.uid,
    required this.email,
    this.socialProvider,
    this.socialId,
    this.phoneNumber = '',
    required this.username,
    required this.gender,
    required this.age,
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
    this.grade = 'Bronze', // 기본값: 'Bronze'
  });

  /// Firestore에서 데이터를 가져와 UserModel로 변환
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
      age: data['age'],
      region: data['region'],
      skinType: data['skinType'],
      skinConditions: List<String>.from(data['skinConditions'] ?? []),
      profileImageUrl: data['profileImageUrl'] ?? '',
      icon: data['icon'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      likedReviews: List<String>.from(data['likedReviews'] ?? []),
      favoriteProducts: List<String>.from(data['favoriteProducts'] ?? []),
      role: data['role'] ?? 'user', // 역할 가져오기 (기본값: 'user')
      grade: data['grade'] ?? 'Bronze', // 등급 가져오기 (기본값: 'Bronze')
    );
  }

  /// Firestore에 데이터를 저장하기 위한 Map 형식으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'socialProvider': socialProvider,
      'socialId': socialId,
      'phoneNumber': phoneNumber,
      'username': username,
      'gender': gender,
      'age': age,
      'region': region,
      'skinType': skinType,
      'skinConditions': skinConditions,
      'profileImageUrl': profileImageUrl,
      'icon': icon,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'likedReviews': likedReviews,
      'favoriteProducts': favoriteProducts,
      'role': role, // 역할 저장
      'grade': grade, // 등급 저장
    };
  }

  /// 이메일 회원가입용 팩토리 메서드
  factory UserModel.fromEmailSignup({
    required String uid,
    required String email,
    required String username,
    required String gender,
    required int age,
    required String region,
    required String skinType,
    required List<String> skinConditions,
    required String icon, 
    required DateTime createdAt, 
    required DateTime lastLoginAt, 
    required String profileImageUrl, 
    required String role, required String grade,
    
  }) {
    return UserModel(
      uid: uid,
      email: email,
      socialProvider: 'email',
      username: username,
      gender: gender,
      age: age,
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

  /// Facebook 로그인용 팩토리 메서드
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
      gender: '', // 추가 정보 필요
      age: 0, // 추가 정보 필요
      region: '', // 추가 정보 필요
      skinType: '', // 추가 정보 필요
      profileImageUrl: user.photoURL ?? '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      role: 'user',
    );
  }

  /// Google 로그인용 팩토리 메서드
  factory UserModel.fromGoogleAuth(UserCredential credential) {
    final user = credential.user!;

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      socialProvider: 'google',
      socialId: user.uid,
      username: user.displayName ?? '',
      phoneNumber: user.phoneNumber ?? '',
      gender: '', // 추가 정보 필요
      age: 0, // 추가 정보 필요
      region: '', // 추가 정보 필요
      skinType: '', // 추가 정보 필요
      profileImageUrl: user.photoURL ?? '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      role: 'user',
    );
  }

  /// 프로필 업데이트를 위한 복사 메서드
  UserModel copyWith({
    String? gender,
    int? age,
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
      age: age ?? this.age,
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
