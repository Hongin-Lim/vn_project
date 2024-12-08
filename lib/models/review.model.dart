import 'package:cloud_firestore/cloud_firestore.dart';

/// 리뷰 데이터 모델
class Review {
  final String id; // 리뷰 ID
  final String productId; // 리뷰가 작성된 제품 ID
  final String userId; // 작성자 ID
  final String title; // 리뷰 제목
  final String content; // 리뷰 내용
  final int rating; // 별점
  final List<String> photoUrls; // 리뷰에 첨부된 사진 URL 목록
  final DateTime createdAt; // 작성 시간

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.title, // 제목 필드 추가
    required this.content,
    required this.rating,
    this.photoUrls = const [], // 기본값: 빈 리스트
    required this.createdAt,
  });

  /// Firestore에서 데이터를 가져올 때
  factory Review.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Review(
      id: doc.id,
      productId: data['productId'],
      userId: data['userId'],
      title: data['title'], // Firestore에서 제목 가져오기
      content: data['content'],
      rating: data['rating'],
      photoUrls: List<String>.from(data['photoUrls'] ?? []), // 사진 목록
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Firestore에 데이터를 저장할 때
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'userId': userId,
      'title': title, // Firestore에 제목 저장
      'content': content,
      'rating': rating,
      'photoUrls': photoUrls, // 사진 URL 목록
      'createdAt': FieldValue.serverTimestamp(), // Firestore 서버 시간
    };
  }
}
