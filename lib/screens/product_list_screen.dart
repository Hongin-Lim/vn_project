import 'package:flutter/material.dart';

import 'product_detail_screen.dart';

class ProductListScreen extends StatelessWidget {
  final List<Map<String, String>> products = [
    {'id': '1', 'name': 'Product 1', 'price': '100'},
    {'id': '2', 'name': 'Product 2', 'price': '200'},
    {'id': '3', 'name': 'Product 3', 'price': '300'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            title: Text(product['name']!),
            subtitle: Text('\$${product['price']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(productId: product['id']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
