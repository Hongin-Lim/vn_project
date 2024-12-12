
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
          Text(
            product.name,
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.description,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('평균 평점', '${product.averageRating.toStringAsFixed(1)}', true),
          _buildStatItem('리뷰 수', '${product.reviewCount}개', false),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool showStar) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (showStar) ...[
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}