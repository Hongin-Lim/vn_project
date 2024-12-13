// lib/screens/review/review_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/review.model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'edit_review_screen.dart';
import 'widgets/review_photos.dart';
import 'widgets/user_info_card.dart';

class ReviewDetailScreen extends StatefulWidget {
  final String reviewId;

  const ReviewDetailScreen({
    required this.reviewId,
    Key? key,
  }) : super(key: key);

  @override
  _ReviewDetailScreenState createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  bool _canModifyReview = false;

  @override
  void initState() {
    super.initState();
    _checkModifyPermission();
  }

  Future<void> _checkModifyPermission() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      final hasPermission = await _firestoreService.canModifyReview(
        currentUser.uid,
        widget.reviewId,
      );
      setState(() => _canModifyReview = hasPermission);
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('리뷰 삭제', style: GoogleFonts.notoSans()),
        content: Text(
          '이 리뷰를 삭제하시겠습니까?\n삭제된 리뷰는 복구할 수 없습니다.',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소', style: GoogleFonts.notoSans()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('삭제', style: GoogleFonts.notoSans()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteReview(widget.reviewId);
        Navigator.pop(context);
      } catch (e) {
        _showErrorMessage(e.toString());
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.notoSans()),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        'Chi tiết đánh giá',
        style: GoogleFonts.notoSans(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: _canModifyReview ? [
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditReviewScreen(reviewId: widget.reviewId),
                ),
              );
              if (result == true) {
                setState(() {});  // 리뷰가 수정되면 화면 새로고침
              }
            } else if (value == 'delete') {
              await _handleDelete();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 20, color: Colors.black87),
                  const SizedBox(width: 8),
                  Text('수정', style: GoogleFonts.notoSans()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('삭제', style: GoogleFonts.notoSans(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ] : null,
    );
  }

  Widget _buildBody() {
    return FutureBuilder<Review?>(
      future: _firestoreService.getReview(widget.reviewId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '리뷰를 불러오는데 실패했습니다',
                  style: GoogleFonts.notoSans(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final review = snapshot.data;
        if (review == null) {
          return Center(
            child: Text(
              '리뷰를 찾을 수 없습니다',
              style: GoogleFonts.notoSans(color: Colors.grey[600]),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (review.photoUrls.isNotEmpty)
                ReviewPhotos(photoUrls: review.photoUrls),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserInfoCard(userId: review.userId),
                    const SizedBox(height: 24),
                    _buildRatingBar(review.rating, review.createdAt),
                    const SizedBox(height: 24),
                    _buildReviewContent(review),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingBar(int rating, DateTime createdAt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: Colors.amber[400],
                size: 28,
              );
            }),
          ),
          Text(
            createdAt.toString().split(' ')[0],
            style: GoogleFonts.notoSans(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewContent(Review review) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review.title,
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            review.content,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}