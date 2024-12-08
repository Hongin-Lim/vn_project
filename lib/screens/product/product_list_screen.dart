import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? category;

  const ProductListScreen({Key? key, this.category}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _products = [];
  List<DocumentSnapshot> _filteredProducts = [];
  String _searchQuery = "";
  String _currentFilter = "Phổ biến";
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_isLoading) return;  // 로딩 중이라면 추가 요청을 하지 않도록

    setState(() {
      _isLoading = true;
    });

    Query query = _firestore.collection('products').limit(20);

    if (widget.category != null && widget.category != 'Tất cả') {
      query = query.where('category', isEqualTo: widget.category);
    }

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final productsSnapshot = await query.get();

    setState(() {
      _isLoading = false;
      _lastDocument = productsSnapshot.docs.isNotEmpty ? productsSnapshot.docs.last : null;
      _products.addAll(productsSnapshot.docs);
      _filteredProducts = _products;
    });
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _products.where((product) {
        final productName = product['name']?.toLowerCase() ?? '';
        return productName.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      if (filter == "Phổ biến") {
        _filteredProducts.sort((a, b) => a['name']!.compareTo(b['name']!));
      } else if (filter == "Nhiều đánh giá") {
        _filteredProducts.sort((a, b) => b['reviewCount']!.compareTo(a['reviewCount']!));
      } else if (filter == "Mới nhất") {
        _filteredProducts = List.from(_products);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.category ?? '상품 목록',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '상품 검색...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (value) => _filterProducts(value),
            ),
          ),
          // 필터 드롭다운
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  "정렬 기준: ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _currentFilter,
                  items: const [
                    DropdownMenuItem(value: "Phổ biến", child: Text("Phổ biến")),
                    DropdownMenuItem(value: "Nhiều đánh giá", child: Text("Nhiều đánh giá")),
                    DropdownMenuItem(value: "Mới nhất", child: Text("Mới nhất")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _applyFilter(value);
                    }
                  },
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  underline: SizedBox(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // 상품 그리드
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('상품이 없습니다.'))
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final productData = product.data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(productId: product.id),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              productData['imageUrl'] ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          productData['name'] ?? '상품 이름 없음',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₩${productData['price'] ?? '알 수 없음'}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // 로딩 스피너
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          // 더 보기 버튼
          if (_lastDocument != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: ElevatedButton(
                  onPressed: _loadProducts,
                  child: Text('더 보기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
