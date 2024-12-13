import 'package:cloud_firestore/cloud_firestore.dart';

/// 리뷰 데이터 모델
class Review {
  final String? id;           // Firestore 문서 ID
  final String productId;     // 리뷰가 작성된 제품 ID
  final String userId;        // 작성자 ID
  final String title;         // 리뷰 제목
  final String content;       // 리뷰 내용
  final int rating;           // 별점 (1-5)
  final List<String> photoUrls; // 리뷰 사진 URL 목록
  final DateTime createdAt;   // 작성 시간
  final DateTime? updatedAt;  // 수정 시간

  Review({
    this.id,
    required this.productId,
    required this.userId,
    required this.title,
    required this.content,
    required this.rating,
    this.photoUrls = const [],
    required this.createdAt,
    this.updatedAt,
  }) {
    // 별점 범위 검증
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Rating must be between 1 and 5');
    }
  }

  /// Firestore 문서로부터 Review 객체 생성
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Document data is null');
    }

    return Review(
      id: doc.id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      rating: (data['rating'] ?? 1).toInt(),
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Firestore에 저장할 데이터 생성
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'userId': userId,
      'title': title,
      'content': content,
      'rating': rating,
      'photoUrls': photoUrls,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// 리뷰 수정을 위한 복사본 생성
  Review copyWith({
    String? title,
    String? content,
    int? rating,
    List<String>? photoUrls,
  }) {
    return Review(
      id: id,
      productId: productId,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// 새로운 리뷰 생성 (createdAt을 현재 시간으로)
  factory Review.create({
    required String productId,
    required String userId,
    required String title,
    required String content,
    required int rating,
    List<String> photoUrls = const [],
  }) {
    return Review(
      productId: productId,
      userId: userId,
      title: title,
      content: content,
      rating: rating,
      photoUrls: photoUrls,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, productId: $productId, userId: $userId, '
        'title: $title, rating: $rating, createdAt: $createdAt)';
  }
}