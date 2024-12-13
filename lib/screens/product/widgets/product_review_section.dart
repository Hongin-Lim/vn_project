// lib/screens/product/widgets/product_review_section.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/firestore_service.dart';
import '../../../utils/profile_util.dart';
import '../../review/review_detail_screen.dart';
import 'review_card.dart';
import 'review_filter_sheet.dart';

class ProductReviewSection extends StatefulWidget {
  final String productId;

  const ProductReviewSection({
    required this.productId,
    Key? key,
  }) : super(key: key);

  @override
  _ProductReviewSectionState createState() => _ProductReviewSectionState();
}

class _ProductReviewSectionState extends State<ProductReviewSection> {
  final _firestoreService = FirestoreService();
  String? _selectedSkinType;
  List<String> _selectedConditions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        if (_selectedSkinType != null || _selectedConditions.isNotEmpty)
          _buildActiveFilters(),
        _buildReviewList(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Đánh giá', // 리뷰
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          TextButton.icon(
            onPressed: () => _showFilterSheet(context),
            icon: const Icon(Icons.filter_list),
            label: Text(
              'Lọc', // 필터
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

  Widget _buildActiveFilters() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_selectedSkinType != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                label: ProfileUtils.skinTypeOptions
                    .firstWhere((e) => e['key'] == _selectedSkinType)['label']!,
                onDelete: () => setState(() => _selectedSkinType = null),
                color: Colors.indigo,
              ),
            ),
          ..._selectedConditions.map((condition) {
            final label = ProfileUtils.skinConditionsOptions
                .firstWhere((e) => e['key'] == condition)['label']!;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                label: label,
                onDelete: () => setState(() {
                  _selectedConditions.remove(condition);
                }),
                color: Colors.teal,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDelete,
    required Color color,
  }) {
    return Chip(
      label: Text(
        label,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      deleteIcon: const Icon(
        Icons.close,
        size: 16,
      ),
      deleteIconColor: Colors.white,
      onDeleted: onDelete,
    );
  }
  void _showFilterSheet(BuildContext context) {
    ReviewFilterSheet.show(
      context,
      selectedSkinType: _selectedSkinType,
      selectedConditions: _selectedConditions,
      onApply: (skinType, conditions) {
        setState(() {
          _selectedSkinType = skinType;
          _selectedConditions = conditions;
        });
      },
    );
  }

  Widget _buildReviewList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getProductReviews(widget.productId),
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

        return FutureBuilder<List<DocumentSnapshot>>(
          future: _filterReviews(snapshot.data!.docs),
          builder: (context, filteredSnapshot) {
            if (filteredSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            final filteredReviews = filteredSnapshot.data ?? [];
            if (filteredReviews.isEmpty) {
              return _buildEmptyFilterState();
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredReviews.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) => ReviewCard(
                review: filteredReviews[index],
                onTap: () => _navigateToReviewDetail(
                  context,
                  filteredReviews[index].id,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> _filterReviews(List<DocumentSnapshot> reviews) async {
    if (_selectedSkinType == null && _selectedConditions.isEmpty) {
      return reviews;
    }

    List<DocumentSnapshot> filteredReviews = [];

    for (var review in reviews) {
      final userData = await _firestoreService.loadUserData(review['userId']);
      if (userData == null) continue;

      bool matchesSkinType = _selectedSkinType == null ||
          userData.skinType == _selectedSkinType;

      bool matchesConditions = _selectedConditions.isEmpty ||
          _selectedConditions.every((condition) =>
              userData.skinConditions.contains(condition));

      if (matchesSkinType && matchesConditions) {
        filteredReviews.add(review);
      }
    }

    return filteredReviews;
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Đã xảy ra lỗi khi tải đánh giá.', // 리뷰를 불러오는데 실패했습니다
          style: GoogleFonts.notoSans(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
        ),
      ),
    );
  }

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
              'Hãy viết đánh giá đầu tiên!', // 첫 번째 리뷰를 작성해보세요!
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

  Widget _buildEmptyFilterState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.filter_list_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy đánh giá phù hợp', // 조건에 맞는 리뷰가 없습니다
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

  void _navigateToReviewDetail(BuildContext context, String reviewId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailScreen(reviewId: reviewId),
      ),
    );
  }
}