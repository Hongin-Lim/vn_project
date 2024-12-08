import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 모델 - Firestore와 연동되는 데이터 클래스
class UserModel {
  final String email; // 이메일 주소
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

  UserModel({
    required this.email,
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
  });

  /// Firestore에서 데이터를 가져와 UserModel로 변환
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      email: data['email'],
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
    );
  }

  /// Firestore에 데이터를 저장하기 위한 Map 형식으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
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
    };
  }
}
