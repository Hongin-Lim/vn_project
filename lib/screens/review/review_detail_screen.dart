import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewDetailScreen extends StatelessWidget {
  final String reviewId; // 리뷰 ID

  const ReviewDetailScreen({
    required this.reviewId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 상세'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: firestore
            .collection('reviews') // `reviews` 컬렉션에서 리뷰 ID로 조회
            .doc(reviewId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                '리뷰를 찾을 수 없습니다.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final review = snapshot.data!.data()!;
          return _buildReviewDetail(context, review);
        },
      ),
    );
  }

  Widget _buildReviewDetail(BuildContext context, Map<String, dynamic> review) {
    final createdAt = review['createdAt'] != null
        ? (review['createdAt'] as Timestamp).toDate()
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 리뷰 제목
          Text(
            review['title'] ?? '제목 없음',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),

          // 별점 표시
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < (review['rating'] ?? 0)
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.orange,
                size: 24,
              );
            }),
          ),
          const SizedBox(height: 12),

          // 작성일
          if (createdAt != null)
            Text(
              '작성일: ${createdAt.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          const SizedBox(height: 12),

          // 리뷰 내용
          Text(
            review['content'] ?? '내용 없음',
            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // 사진 섹션
          if (review['photoUrls'] != null && review['photoUrls'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '첨부된 사진',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (review['photoUrls'] as List).length,
                    itemBuilder: (context, index) {
                      final photoUrl = review['photoUrls'][index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            photoUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),

          // 작성자 정보
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            '작성자 정보',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          const SizedBox(height: 8),
          Text(
            review['userId'] ?? '익명 사용자', // userId 또는 author 표시
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
