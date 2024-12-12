// lib/screens/product/widgets/review_card.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/grade_utils.dart';

/// 개별 리뷰 카드 위젯
class ReviewCard extends StatelessWidget {
  final DocumentSnapshot review;
  final VoidCallback onTap;

  const ReviewCard({
    required this.review,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reviewData = review.data() as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfo(reviewData),
          _buildContent(reviewData),
          _buildPhotos(reviewData),
          _buildViewMoreButton(),
        ],
      ),
    );
  }

  /// 사용자 정보 섹션
  Widget _buildUserInfo(Map<String, dynamic> reviewData) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(reviewData['userId'])
          .get(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              _buildUserAvatar(userData),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserName(userData),
                    const SizedBox(height: 4),
                    _buildUserTags(userData),
                    const SizedBox(height: 4),
                    _buildRating(reviewData['rating'] ?? 0),
                  ],
                ),
              ),
              _buildReviewDate(reviewData['createdAt'] as Timestamp?),
            ],
          ),
        );
      },
    );
  }

  /// 리뷰 내용 섹션
  Widget _buildContent(Map<String, dynamic> reviewData) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reviewData['title'] ?? '',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reviewData['content'] ?? '',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 리뷰 사진 섹션
  Widget _buildPhotos(Map<String, dynamic> reviewData) {
    final photoUrls = reviewData['photoUrls'] as List?;
    if (photoUrls == null || photoUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: photoUrls.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              photoUrls[index],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: Icon(Icons.error_outline, color: Colors.grey[400]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 더보기 버튼
  Widget _buildViewMoreButton() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12),
        ),
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.indigo,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '자세히 보기',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  /// 사용자 아바타 구성
  Widget _buildUserAvatar(Map<String, dynamic>? userData) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.indigo.withOpacity(0.1),
          backgroundImage: (userData != null &&
              userData['profileImageUrl'] != null &&
              userData['profileImageUrl'].toString().isNotEmpty)
              ? NetworkImage(userData['profileImageUrl'])
              : null,
          child: (userData == null ||
              userData['profileImageUrl'] == null ||
              userData['profileImageUrl'].toString().isEmpty)
              ? (userData?['icon'] != null)
              ? Text(
            userData!['icon'],
            style: const TextStyle(fontSize: 24),
          )
              : Icon(
            Icons.person_outline_rounded,
            size: 28,
            color: Colors.indigo[400],
          )
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              getGradeIcon(userData?['grade']),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  /// 사용자 이름 구성
  Widget _buildUserName(Map<String, dynamic>? userData) {
    return Text(
      userData?['username'] ?? 'Người dùng ẩn danh',
      style: GoogleFonts.notoSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  /// 사용자 태그 구성
  Widget _buildUserTags(Map<String, dynamic>? userData) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (userData?['skinType'] != null)
          _buildTag(
            userData!['skinType'],
            Colors.indigo.withOpacity(0.1),
            Colors.indigo,
          ),
        if (userData?['skinConditions'] != null)
          ...(userData!['skinConditions'] as List).map(
                (condition) => _buildTag(
              condition,
              Colors.teal.withOpacity(0.1),
              Colors.teal,
            ),
          ),
      ],
    );
  }

  /// 태그 위젯 구성
  Widget _buildTag(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          color: textColor,
        ),
      ),
    );
  }

  /// 별점 구성
  Widget _buildRating(int rating) {
    return Row(
      children: List.generate(
        5,
            (index) => Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber[400],
          size: 16,
        ),
      ),
    );
  }

  /// 리뷰 작성일 구성
  Widget _buildReviewDate(Timestamp? createdAt) {
    if (createdAt == null) return const SizedBox.shrink();

    return Text(
      createdAt.toDate().toString().split(' ')[0],
      style: GoogleFonts.notoSans(
        fontSize: 12,
        color: Colors.grey[500],
      ),
    );
  }
}