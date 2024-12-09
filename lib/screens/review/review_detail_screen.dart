import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/grade_utils.dart';

class ReviewDetailScreen extends StatelessWidget {
  final String reviewId;

  const ReviewDetailScreen({
    required this.reviewId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Chi tiết đánh giá',
          style: GoogleFonts.notoSans(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: firestore.collection('reviews').doc(reviewId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy bài đánh giá',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final review = snapshot.data!.data()!;

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: firestore.collection('users').doc(review['userId']).get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return _buildReviewDetail(context, review, null);
              }
              final userData = userSnapshot.data!.data();
              return _buildReviewDetail(context, review, userData);
            },
          );
        },
      ),
    );
  }

  Widget _buildReviewDetail(BuildContext context, Map<String, dynamic> review, Map<String, dynamic>? userData) {
    final createdAt = review['createdAt'] != null
        ? (review['createdAt'] as Timestamp).toDate()
        : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 리뷰 이미지 섹션
          if (review['photoUrls'] != null && review['photoUrls'].isNotEmpty)
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: (review['photoUrls'] as List).length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[100]!),
                        ),
                        child: Image.network(
                          review['photoUrls'][index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: 48,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                // 그라데이션 오버레이
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 정보 섹션
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 프로필 이미지와 아이콘
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey[50],
                            backgroundImage: (userData != null &&
                                userData['profileImageUrl'] != null &&
                                userData['profileImageUrl'].toString().isNotEmpty)
                                ? NetworkImage(userData['profileImageUrl'])
                                : null,
                            child: (userData == null ||
                                userData['profileImageUrl'] == null ||
                                userData['profileImageUrl'].toString().isEmpty)
                                ? Container(
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (userData?['icon'] != null)
                                    Text(
                                      userData?['icon'],
                                      style: const TextStyle(fontSize: 34),
                                    )
                                  else
                                    Icon(
                                      Icons.person,
                                      size: 32,
                                      color: Colors.indigo[300],
                                    ),
                                ],
                              ),
                            )
                                : null,
                          ),
                          // 등급 뱃지
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: getGradeColor(userData?['grade']),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                getGradeIcon(userData?['grade']),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          // Admin 뱃지 (있는 경우)
                          if (userData?['role'] == 'admin')
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red[400],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData?['username'] ?? 'Người dùng ẩn danh',
                              style: GoogleFonts.notoSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildInfoChip(
                                  label: userData?['skinType'] ?? 'Không xác định',
                                  color: Colors.indigo,
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  label: '${userData?['age'].toString() ?? ''} tuổi',
                                  color: Colors.amber[700]!,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 별점과 날짜
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < (review['rating'] ?? 0)
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.amber[400],
                              size: 28,
                            );
                          }),
                        ],
                      ),
                      if (createdAt != null)
                        Text(
                          createdAt.toLocal().toString().split(' ')[0],
                          style: GoogleFonts.notoSans(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 제목
                Text(
                  review['title'] ?? 'Không có tiêu đề',
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // 내용
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    review['content'] ?? 'Không có nội dung',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 피부 상태 태그
                if (userData != null && userData['skinConditions'] != null) ...[
                  Text(
                    'Tình trạng da',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (userData['skinConditions'] as List)
                        .map((condition) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        condition,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}