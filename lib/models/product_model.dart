import 'package:cloud_firestore/cloud_firestore.dart';

/// 제품 데이터 모델
class Product {
  final String? id;         // Firestore 문서 ID (선택적)
  final String name;        // 제품 이름
  final String description; // 제품 설명
  final String imageUrl;    // 제품 이미지 URL
  final String category;    // 카테고리
  final int reviewCount;    // 리뷰 수
  final double averageRating; // 평균 평점

  Product({
    this.id,               // id는 선택적 매개변수로 변경
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.reviewCount = 0,
    this.averageRating = 0.0,
  });

  /// Firestore 문서로부터 Product 객체 생성 (id 포함)
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,          // 문서에서 가져올 때는 id 포함
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      reviewCount: data['reviewCount'] ?? 0,
      averageRating: (data['averageRating'] ?? 0).toDouble(),
    );
  }

  /// Firestore에 저장할 데이터 (id 제외)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'reviewCount': reviewCount,
      'averageRating': averageRating,
    };
  }
}