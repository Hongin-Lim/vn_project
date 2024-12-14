
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/product_model.dart';

/// 상품 정보 섹션 위젯
class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({
    required this.product,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 브랜드명 추가
          Text(
            product.brand,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          // 해시태그 목록 추가
          if (product.hashtags.isNotEmpty) ...[
            _buildHashtags(),
            const SizedBox(height: 20),
          ],
          Text(
            product.description,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildHashtags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: product.hashtags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '#$tag',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: const Color(0xFF4A5460),
              fontWeight: FontWeight.w500,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('평균 평점', '${product.averageRating.toStringAsFixed(1)}', true),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[200],
          ),
          _buildStatItem('리뷰 수', '${product.reviewCount}개', false),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool showStar) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showStar) ...[
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFA726),
                  size: 22,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
