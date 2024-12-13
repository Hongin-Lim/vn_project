
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../review/add_review_screen.dart';
import '../product_analysis_screen.dart';

/// 상품 상세 화면의 액션 버튼들(성분 분석, 리뷰 작성)을 표시하는 위젯
class ProductActionButtons extends StatelessWidget {
  final String productId;
  final String productName;
  final String productImage;

  const ProductActionButtons({
    required this.productId,
    required this.productName,
    required this.productImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildAnalysisButton(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildReviewButton(context),
          ),
        ],
      ),
    );
  }

  /// 성분 분석 버튼
  Widget _buildAnalysisButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IngredientAnalysisScreen(),
          ),
        );
      },
      icon: const Icon(Icons.science),
      label: Text(
        'Xem thành phần',
        style: GoogleFonts.notoSans(),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
        elevation: 0,
        side: const BorderSide(color: Colors.indigo),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 리뷰 작성 버튼
  Widget _buildReviewButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddReviewScreen(
              productId: productId,
              productName: productName,
              productImage: productImage,
            ),
          ),
        );
      },
      icon: const Icon(Icons.edit, color: Colors.white),
      label: Text(
        'Viết đánh giá',
        style: GoogleFonts.notoSans(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}