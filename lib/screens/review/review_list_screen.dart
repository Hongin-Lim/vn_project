import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewListScreen extends StatelessWidget {
  final String productId; // 리뷰를 조회할 제품 ID

  const ReviewListScreen({
    required this.productId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 목록'), // 카테고리 제거, 그냥 '리뷰 목록'으로 변경
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore
            .collection('reviews') // `reviews` 컬렉션을 직접 조회
            .where('productId', isEqualTo: productId) // 해당 제품의 리뷰만 필터링
            .orderBy('createdAt', descending: true) // 최신 리뷰 우선
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                '리뷰가 없습니다.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reviews.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final review = reviews[index].data();
              return _buildReviewCard(
                title: review['title'] ?? '제목 없음',
                content: review['content'] ?? '내용 없음',
                rating: (review['rating'] ?? 0.0) is num
                    ? (review['rating'] as num).toDouble()
                    : 0.0,
                createdAt: review['createdAt'] as Timestamp?,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewCard({
    required String title,
    required String content,
    required double rating,
    Timestamp? createdAt,
  }) {
    final formattedDate = createdAt != null
        ? DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 및 별점
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 내용
            Text(
              content,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // 작성일
            if (formattedDate != null)
              Text(
                '작성일: ${formattedDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
          ],
        ),
      ),
    );
  }
}
