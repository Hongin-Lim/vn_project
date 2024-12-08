import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    if (_isLoading) return;

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
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            widget.category ?? '상품 목록',
            style: GoogleFonts.roboto(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.filter_alt_outlined, color: Colors.black87),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '상품 검색...',
                  hintStyle: GoogleFonts.roboto(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 22),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                onChanged: (value) => _filterProducts(value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    "정렬 기준: ",
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _currentFilter,
                    items: [
                      DropdownMenuItem(
                        value: "Phổ biến",
                        child: Text(
                          "Phổ biến",
                          style: GoogleFonts.roboto(),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Nhiều đánh giá",
                        child: Text(
                          "Nhiều đánh giá",
                          style: GoogleFonts.roboto(),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Mới nhất",
                        child: Text(
                          "Mới nhất",
                          style: GoogleFonts.roboto(),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        _applyFilter(value);
                      }
                    },
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    underline: SizedBox(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(
                child: Text(
                  '상품이 없습니다.',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              )
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
                          builder: (context) =>
                              ProductDetailScreen(productId: product.id),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        productData['imageUrl'] ?? '',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.3),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productData['name'] ?? '상품 이름 없음',
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${productData['reviewCount'] ?? 0}개의 리뷰',
                                      style: GoogleFonts.roboto(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_lastDocument != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: TextButton(
                    onPressed: _loadProducts,
                    child: Text(
                      '더 보기',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: TextButton.styleFrom(
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
      ),
    );
  }
}