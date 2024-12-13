// lib/screens/review/widgets/product_info_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/product_model.dart';
import '../../../services/firestore_service.dart';
import '../../product/product_detail_screen.dart';

class ProductInfoCard extends StatelessWidget {
  final String productId;
  final _firestoreService = FirestoreService();

  ProductInfoCard({
    required this.productId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
      future: _firestoreService.getProductById(productId),
      builder: (context, snapshot) {
        final product = snapshot.data;

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
          child: InkWell(
            onTap: () async {
              if (product != null) {
                try {
                  await Navigator.pushNamed(
                    context,
                    '/product/detail', // 라우터 방식
                    arguments: productId,
                  );
                } catch (e) {
                  // fallback 처리
                  if (context.mounted) {  // context가 아직 유효한지 확인
                    Navigator.push( //Navigator.push 방식
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(productId: productId),
                      ),
                    );
                  }
                }
              }
            },
            child: Row(
              children: [
                // 상품 이미지
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: product?.imageUrl != null ? DecorationImage(
                      image: NetworkImage(product!.imageUrl),
                      fit: BoxFit.cover,
                    ) : null,
                  ),
                  child: product?.imageUrl == null ? Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey[400],
                  ) : null,
                ),
                const SizedBox(width: 16),
                // 상품 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?.name ?? '상품 정보 없음',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product?.category ?? '',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // 화살표 아이콘
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}