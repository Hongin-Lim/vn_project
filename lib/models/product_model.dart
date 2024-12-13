import 'package:cloud_firestore/cloud_firestore.dart';

/// 제품 데이터 모델
class Product {
  final String? id;            // Firestore 문서 ID
  final String name;           // 제품 이름
  final String description;    // 제품 설명
  final String imageUrl;       // 제품 이미지 URL
  final String category;       // 카테고리
  final int reviewCount;       // 리뷰 수
  final double averageRating;  // 평균 평점
  final DateTime createdAt;    // 생성 시간
  final DateTime? updatedAt;   // 수정 시간

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
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
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
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
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'reviewCount': reviewCount,
      'averageRating': averageRating,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// 제품 정보 수정을 위한 복사본 생성 updateProduct() 메서드랑 차이 있음. 현재 안씀.
  Product copyWith({
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    int? reviewCount,
    double? averageRating,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      // 같은 의미
      // description: description == null ? this.description : description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      reviewCount: reviewCount ?? this.reviewCount,
      averageRating: averageRating ?? this.averageRating,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// 새로운 제품 생성 (createdAt을 현재 시간으로)
  factory Product.create({
    required String name,
    required String description,
    required String imageUrl,
    required String category,
  }) {
    return Product(
      name: name,
      description: description,
      imageUrl: imageUrl,
      category: category,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: $category, '
        'reviewCount: $reviewCount, averageRating: $averageRating)';
  }
}