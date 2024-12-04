import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  ProductDetailScreen({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
      ),
      body: Column(
        children: [
          Text(
            'Product ID: $productId',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Product Description...'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 좋아요 기능 추가
            },
            child: Text('Like'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 리뷰 작성 화면 이동
            },
            child: Text('Write a Review'),
          ),
        ],
      ),
    );
  }
}
