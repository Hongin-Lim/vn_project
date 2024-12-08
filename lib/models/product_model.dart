import 'package:cloud_firestore/cloud_firestore.dart';

/// 제품 데이터 모델
class Product {
  final String id; // 제품 ID
  final String name; // 제품 이름
  final String description; // 제품 설명
  final String imageUrl; // 제품 이미지 URL
  final String category; // 카테고리
  final int reviewCount; // 리뷰 수
  final double averageRating; // 평균 평점

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.reviewCount,
    required this.averageRating,
  });

  /// Firestore에서 데이터를 가져올 때
  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Product(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      category: data['category'],
      reviewCount: data['reviewCount'] ?? 0,
      averageRating: (data['averageRating'] ?? 0).toDouble(),
    );
  }

  /// Firestore에 데이터를 저장할 때
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
