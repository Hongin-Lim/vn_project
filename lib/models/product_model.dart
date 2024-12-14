import 'package:cloud_firestore/cloud_firestore.dart';

/// 제품 데이터 모델
class Product {
  final String? id;            // Firestore 문서 ID
  final String name;           // 제품 이름
  final String brand;          // 브랜드 이름
  final String description;    // 제품 설명
  final String imageUrl;       // 제품 이미지 URL
  final String category;       // 카테고리
  final List<String> hashtags; // 해시태그 목록
  final int reviewCount;       // 리뷰 수
  final double averageRating;  // 평균 평점
  final DateTime createdAt;    // 생성 시간
  final DateTime? updatedAt;   // 수정 시간

  Product({
    this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.hashtags,
    this.reviewCount = 0,
    this.averageRating = 0.0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Firestore 문서로부터 Product 객체 생성
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Document data is null');
    }

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      hashtags: List<String>.from(data['hashtags'] ?? []),
      reviewCount: (data['reviewCount'] ?? 0).toInt(),
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] == null)
          ? DateTime.now()
          : (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] == null
          ? null
          : (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Firestore에 저장할 데이터
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'brand': brand,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'hashtags': hashtags,
      'reviewCount': reviewCount,
      'averageRating': averageRating,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// 제품 정보 수정을 위한 복사본 생성
  Product copyWith({
    String? name,
    String? brand,
    String? description,
    String? imageUrl,
    String? category,
    List<String>? hashtags,
    int? reviewCount,
    double? averageRating,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      hashtags: hashtags ?? this.hashtags,
      reviewCount: reviewCount ?? this.reviewCount,
      averageRating: averageRating ?? this.averageRating,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// 새로운 제품 생성 (createdAt을 현재 시간으로)
  factory Product.create({
    required String name,
    required String brand,
    required String description,
    required String imageUrl,
    required String category,
    List<String> hashtags = const [],
  }) {
    return Product(
      name: name,
      brand: brand,
      description: description,
      imageUrl: imageUrl,
      category: category,
      hashtags: hashtags,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, brand: $brand, category: $category, '
        'hashtags: $hashtags, reviewCount: $reviewCount, averageRating: $averageRating)';
  }
}