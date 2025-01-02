import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 사용자 정보를 관리하는 모델 클래스
/// Firebase Authentication 및 Firestore와 연동하여 사용자 데이터를 처리합니다.
/// 베트남 법령 147/2024/NĐ-CP 준수를 위한 전화번호 인증 관련 필드를 포함합니다.
class UserModel {
  /// Firebase Authentication UID
  final String uid;

  /// 사용자 이메일 주소
  final String email;

  /// 소셜 로그인 제공자 (예: 'google', 'facebook', 'email')
  final String socialProvider;

  /// 소셜 로그인 제공자의 사용자 ID
  final String socialId;

  /// 사용자 전화번호 (베트남 법령 준수용)
  final String phoneNumber;

  /// 전화번호 인증 완료 여부
  final bool isPhoneVerified;

  /// 전화번호 인증 완료 시점
  final DateTime? phoneVerifiedAt;

  /// 계정 상태 ('active', 'restricted', 'suspended')
  /// - active: 정상 활성화 상태
  /// - restricted: 제한된 상태 (전화번호 미인증 등)
  /// - suspended: 정지된 상태
  final String accountStatus;

  /// 상호작용 가능 여부 (댓글, 게시글 작성 등)
  /// 베트남 법령에 따라 전화번호 인증 전에는 false로 설정
  final bool canInteract;

  /// 사용자 이름/닉네임
  final String username;

  /// 성별 ('male', 'female', 'other')
  final String gender;

  /// 생년월일
  final DateTime birthDate;

  /// 지역 정보
  final String region;

  /// 피부 타입
  final String skinType;

  /// 피부 상태/조건 목록
  final List<String> skinConditions;

  /// 프로필 이미지 URL
  final String profileImageUrl;

  /// 사용자 아이콘
  final String icon;

  /// 계정 생성 시점
  final DateTime createdAt;

  /// 마지막 로그인 시점
  final DateTime lastLoginAt;

  /// 좋아요한 리뷰 ID 목록
  final List<String> likedReviews;

  /// 즐겨찾기한 제품 ID 목록
  final List<String> favoriteProducts;

  /// 사용자 역할 ('user', 'admin' 등)
  final String role;

  /// 사용자 등급 ('Bronze', 'Silver', 'Gold' 등)
  final String grade;

  /// 연결된 소셜 로그인 제공자 목록
  final List<String> linkedProviders;

  /// UserModel 생성자
  /// [accountStatus]와 [canInteract]는 베트남 법령 준수를 위해
  /// 기본적으로 제한된 상태로 설정됩니다.
  UserModel({
    required this.uid,
    required this.email,
    this.socialProvider = '', // 기본값 빈 문자열
    this.socialId = '', // 기본값 빈 문자열
    this.phoneNumber = '',
    this.isPhoneVerified = false,
    this.phoneVerifiedAt,
    this.accountStatus = 'restricted', // 기본값: 제한된 상태
    this.canInteract = false, // 기본값: 상호작용 불가
    required this.username,
    required this.gender,
    required this.birthDate,
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
    this.linkedProviders = const [], // 새로 추가
  });

  /// Firestore 문서로부터 UserModel 객체를 생성하는 팩토리 생성자
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'],
      socialProvider: data['socialProvider'],
      socialId: data['socialId'],
      phoneNumber: data['phoneNumber'] ?? '',
      isPhoneVerified: data['isPhoneVerified'] ?? false,
      phoneVerifiedAt: data['phoneVerifiedAt'] != null
          ? (data['phoneVerifiedAt'] as Timestamp).toDate()
          : null,
      accountStatus: data['accountStatus'] ?? 'restricted',
      canInteract: data['canInteract'] ?? false,
      username: data['username'],
      gender: data['gender'],
      birthDate: (data['birthDate'] as Timestamp).toDate(),
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
      linkedProviders: List<String>.from(data['linkedProviders'] ?? []),
    );
  }

  /// UserModel 객체를 Firestore 문서 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'socialProvider': socialProvider,
      'socialId': socialId,
      'phoneNumber': phoneNumber,
      'isPhoneVerified': isPhoneVerified,
      'phoneVerifiedAt':
          phoneVerifiedAt != null ? Timestamp.fromDate(phoneVerifiedAt!) : null,
      'accountStatus': accountStatus,
      'canInteract': canInteract,
      'username': username,
      'gender': gender,
      'birthDate': Timestamp.fromDate(birthDate),
      'region': region,
      'skinType': skinType,
      'skinConditions': skinConditions,
      'profileImageUrl': profileImageUrl,
      'icon': icon,
      'createdAt': Timestamp.fromDate(createdAt),
      // serverTimestamp() 대신 실제 값 사용
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      // serverTimestamp() 대신 실제 값 사용
      'likedReviews': likedReviews,
      'favoriteProducts': favoriteProducts,
      'role': role,
      'grade': grade,
      'linkedProviders': linkedProviders,
    };
  }

  /// 이메일 회원가입으로 UserModel 객체를 생성하는 팩토리 생성자
  factory UserModel.fromEmailSignup({
    required String uid,
    required String email,
    required String username,
    required String gender,
    required DateTime birthDate,
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
      birthDate: birthDate,
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

  /// 소셜 로그인 연결을 위한 복사 메서드
  UserModel withLinkedProvider(String provider) {
    return UserModel(
      uid: uid,
      email: email,
      socialProvider: socialProvider,
      socialId: socialId,
      phoneNumber: phoneNumber,
      isPhoneVerified: isPhoneVerified,
      phoneVerifiedAt: phoneVerifiedAt,
      accountStatus: accountStatus,
      canInteract: canInteract,
      username: username,
      gender: gender,
      birthDate: birthDate,
      region: region,
      skinType: skinType,
      skinConditions: skinConditions,
      profileImageUrl: profileImageUrl,
      icon: icon,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      likedReviews: likedReviews,
      favoriteProducts: favoriteProducts,
      role: role,
      grade: grade,
      linkedProviders: [...linkedProviders, provider], // 새로운 provider 추가
    );
  }

  /// Facebook 로그인으로 UserModel 객체를 생성하는 팩토리 생성자
  factory UserModel.fromFacebookAuth(
      UserCredential credential, Map<String, dynamic> userData) {
    final user = credential.user!;

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      socialProvider: 'facebook',
      socialId: (userData['id'] ?? '').toString(),
      // null일 경우 빈 문자열로 처리
      username: userData['name'] ?? user.displayName ?? '',
      phoneNumber: user.phoneNumber ?? '',
      gender: '',
      birthDate: DateTime.now(),
      region: 'Vietnam',
      // 기본값 설정
      skinType: 'Normal',
      // 기본값 설정
      profileImageUrl:
          userData['picture']?['data']?['url'] ?? user.photoURL ?? '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      role: 'user',
      grade: 'Bronze',
      linkedProviders: ['facebook'], // 초기 연결된 provider 설정
    );
  }

  /// Google 로그인으로 UserModel 객체를 생성하는 팩토리 생성자
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
      // Google에서 제공하지 않음
      birthDate: DateTime.now(),
      // 추가 정보 입력 필요
      region: 'Vietnam',
      // 기본값 설정
      skinType: 'Normal',
      // 기본값 설정
      profileImageUrl: user.photoURL ?? '',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      role: 'user',
      grade: 'Bronze',
      // grade 추가
      linkedProviders: ['google'], // 초기 연결된 provider 설정
    );
  }

  /// 특정 소셜 로그인이 연결되어 있는지 확인하는 메서드
  bool hasLinkedProvider(String provider) {
    return linkedProviders.contains(provider);
  }

  /// 연결된 소셜 로그인 개수를 반환하는 메서드
  int get linkedProvidersCount => linkedProviders.length;

  /// 사용자 정보 업데이트를 위한 copyWith 메서드
  /// 전화번호 인증 관련 필드는 별도의 메서드로 관리하여 안전성 확보
  /// 사용자 정보 업데이트를 위한 copyWith 메서드
  UserModel copyWith({
    String? gender,
    DateTime? birthDate,
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
      isPhoneVerified: isPhoneVerified,
      phoneVerifiedAt: phoneVerifiedAt,
      accountStatus: accountStatus,
      canInteract: canInteract,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
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
      linkedProviders: linkedProviders, // 기존 linkedProviders 유지
    );
  }

  /// 전화번호 인증 완료 시 사용자 상태를 업데이트하는 메서드
  UserModel withPhoneVerified({
    required String phoneNumber,
    required DateTime verifiedAt,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      socialProvider: socialProvider,
      socialId: socialId,
      phoneNumber: phoneNumber,
      isPhoneVerified: true,
      phoneVerifiedAt: verifiedAt,
      accountStatus: 'active',
      canInteract: true,
      username: username,
      gender: gender,
      birthDate: birthDate,
      region: region,
      skinType: skinType,
      skinConditions: skinConditions,
      profileImageUrl: profileImageUrl,
      icon: icon,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      likedReviews: likedReviews,
      favoriteProducts: favoriteProducts,
      role: role,
      grade: grade,
      linkedProviders: linkedProviders, // 기존 linkedProviders 유지
    );
  }

  /// 사용자가 특정 기능을 사용할 수 있는지 확인하는 헬퍼 메서드
  bool canUseFeature(String feature) {
    // 전화번호 인증이 필요한 기능 목록
    const phoneVerificationRequiredFeatures = [
      'comment',
      'post',
      'review',
      'like',
    ];

    // 전화번호 인증이 필요한 기능인 경우
    if (phoneVerificationRequiredFeatures.contains(feature)) {
      return isPhoneVerified && canInteract && accountStatus == 'active';
    }

    // 기본적인 기능은 계정이 활성화 상태이면 사용 가능
    return accountStatus == 'active';
  }
}
