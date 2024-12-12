// lib/screens/product/widgets/product_review_section.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/firestore_service.dart';
import '../../review/review_detail_screen.dart';
import 'review_card.dart';


/// 상품의 리뷰 목록을 표시하는 섹션 위젯
class ProductReviewSection extends StatelessWidget {
  final String productId;
  final _firestoreService = FirestoreService();

  ProductReviewSection({
    required this.productId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        _buildReviewList(),
      ],
    );
  }

  /// 헤더 섹션 구성
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '리뷰',
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: 전체 리뷰 화면으로 이동
            },
            child: Text(
              '전체보기',
              style: GoogleFonts.notoSans(
                color: Colors.indigo,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 리뷰 목록 구성
  Widget _buildReviewList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getProductReviews(productId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) => ReviewCard(
            review: snapshot.data!.docs[index],
            onTap: () => _navigateToReviewDetail(
              context,
              snapshot.data!.docs[index].id,
            ),
          ),
        );
      },
    );
  }

  /// 에러 상태 UI
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          '리뷰를 불러오는데 실패했습니다.',
          style: GoogleFonts.notoSans(color: Colors.red),
        ),
      ),
    );
  }

  /// 로딩 상태 UI
  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// 빈 상태 UI
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '첫 번째 리뷰를 작성해보세요!',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 리뷰 상세 화면으로 이동
  void _navigateToReviewDetail(BuildContext context, String reviewId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailScreen(reviewId: reviewId),
      ),
    );
  }
}