// lib/screens/home/recent_reviews_section.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../review/review_detail_screen.dart';

/// 최근 리뷰 섹션을 표시하는 위젯
class RecentReviewsSection extends StatelessWidget {
  final FirebaseFirestore firestore;
  final bool isDesktop;
  final bool isTablet;

  const RecentReviewsSection({
    Key? key,
    required this.firestore,
    required this.isDesktop,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getReviewsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final reviews = snapshot.data!.docs;

        if (isDesktop || isTablet) {
          return _buildGrid(context, reviews);
        }

        return _buildList(context, reviews);
      },
    );
  }

  /// 리뷰 스트림 가져오기
  Stream<QuerySnapshot> _getReviewsStream() {
    return firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(isDesktop ? 6 : 4)
        .snapshots();
  }

  /// 로딩 상태 UI
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, __) => _buildShimmerCard(),
      ),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không có đánh giá nào.',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 그리드 레이아웃
  Widget _buildGrid(BuildContext context, List<QueryDocumentSnapshot> reviews) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        childAspectRatio: isDesktop ? 1.2 : 1.1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: reviews.length,
      itemBuilder: (context, index) =>
          _buildReviewCard(
            context,
            reviews[index],
            true,
          ),
    );
  }

  /// 리스트 레이아웃
  Widget _buildList(BuildContext context, List<QueryDocumentSnapshot> reviews) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        final productId = review['productId'];

        return FutureBuilder<DocumentSnapshot>(
          future: firestore.collection('products').doc(productId).get(),
          builder: (context, productSnapshot) {
            if (productSnapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerCard();
            }

            if (productSnapshot.hasError || !productSnapshot.hasData) {
              return _buildErrorCard();
            }

            final product = productSnapshot.data!;
            final productName = product['name'];

            return _buildReviewCard(
              context,
              review,
              false,
              productName: productName,
            );
          },
        );
      },
    );
  }

  /// 시머 효과 카드
  Widget _buildShimmerCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: 200,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  /// 에러 상태 카드
  Widget _buildErrorCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '상품 정보를 불러오는 데 실패했습니다.',
          style: GoogleFonts.notoSans(color: Colors.red[400]),
        ),
      ),
    );
  }

  /// 리뷰 카드 구성
  Widget _buildReviewCard(BuildContext context,
      DocumentSnapshot review,
      bool isGrid, {
        String? productName,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _onReviewTap(context, review.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(review, productName),
              const SizedBox(height: 12),
              _buildRating(review),
              const SizedBox(height: 12),
              _buildContent(review),
            ],
          ),
        ),
      ),
    );
  }

  /// 사용자 정보 구성
  Widget _buildUserInfo(DocumentSnapshot review, String? productName) {
    return FutureBuilder<DocumentSnapshot>(
      future: firestore.collection('users').doc(review['userId']).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorUserInfo();
        }

        if (!snapshot.hasData) {
          return _buildLoadingUserInfo();
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        return _buildUserInfoContent(userData, productName);
      },
    );
  }
  /// 에러 상태의 사용자 정보
  Widget _buildErrorUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.deepPurple[100],
          radius: isDesktop ? 24 : 20,
          child: const Text('!', style: TextStyle(color: Colors.deepPurple)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Error loading user data',
            style: GoogleFonts.notoSans(color: Colors.red),
          ),
        ),
      ],
    );
  }

  /// 로딩 상태의 사용자 정보
  Widget _buildLoadingUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.deepPurple[100],
          radius: isDesktop ? 24 : 20,
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2,
          ),
        ),
      ],
    );
  }

  /// 사용자 정보 내용
  Widget _buildUserInfoContent(Map<String, dynamic>? userData, String? productName) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: isDesktop ? 24 : 20,
          child: (userData == null ||
              userData['profileImageUrl'] == null ||
              userData['profileImageUrl'].toString().isEmpty)
              ? Text(
            userData?['icon'] ?? '👤',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
            ),
          )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (productName != null)
                Text(
                  productName,
                  style: GoogleFonts.notoSans(
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 18 : 16,
                    // color: Colors.deepPurple,
                    color: Colors.pinkAccent[100],
                  ),
                ),
              if (userData != null)
                Text(
                  userData['username'] ?? 'Anonymous User',
                  style: GoogleFonts.notoSans(
                    fontSize: isDesktop ? 14 : 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 별점 구성
  Widget _buildRating(DocumentSnapshot review) {
    return RatingBar.builder(
      initialRating: (review['rating'] ?? 0).toDouble(),
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: isDesktop ? 20 : 16,
      ignoreGestures: true,
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (_) {}, // 읽기 전용이므로 업데이트 불필요
    );
  }

  /// 리뷰 내용 구성
  Widget _buildContent(DocumentSnapshot review) {
    return Text(
      review['content'] ?? '',
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.notoSans(
        fontSize: isDesktop ? 14 : 12,
        color: Colors.black54,
        height: 1.5,
      ),
    );
  }

  /// 리뷰 상세 페이지로 이동
  void _onReviewTap(BuildContext context, String reviewId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailScreen(
          reviewId: reviewId,
        ),
      ),
    );
  }
}