import 'package:flutter/material.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final List<Map<String, String>> _products = [
    {'name': 'Torriden Serum', 'price': '\đ 120,000', 'image': 'https://hongin-lim.github.io/vn_project/images/products/torriden.jpg'},
    {'name': 'Bioderma', 'price': '\đ 400,000', 'image': 'https://hongin-lim.github.io/vn_project/images/products/bioderma.jpg'},
    {'name': 'goodal Serum', 'price': '\đ 70,000', 'image': 'https://hongin-lim.github.io/vn_project/images/products/goodal2.jpg'},
    {'name': 'Wellage AMPOULE', 'price': '\đ 550,000', 'image': 'https://hongin-lim.github.io/vn_project/images/products/wellage.jpg'},
    {'name': 'Torriden', 'price': '\đ 120,000', 'image': 'https://hongin-lim.github.io/vn_project/images/products/goodal.jpg'},
  ];

  List<Map<String, String>> _filteredProducts = [];
  String _searchQuery = "";
  String _currentFilter = "Phổ biến"; // 기본 필터: 인기순

  @override
  void initState() {
    super.initState();
    _filteredProducts = _products; // 초기 상태에서 모든 상품 표시
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _products
          .where((product) =>
          product['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      if (filter == "Phổ biến") {
        // 인기순 정렬 (예: 이름순으로 임시 정렬)
        _filteredProducts.sort((a, b) => a['name']!.compareTo(b['name']!));
      } else if (filter == "Nhiều đánh giá") {
        // 리뷰 많은 순 (이름 역순으로 임시 정렬)
        _filteredProducts.sort((a, b) => b['name']!.compareTo(a['name']!));
      } else if (filter == "Mới nhất") {
        // 최신 등록 순 (기존 데이터 순서 유지)
        _filteredProducts = List.from(_products); // 원래 순서 유지
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách sản phẩm'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) => _filterProducts(value),
            ),
          ),
          // 드롭다운 필터
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text("Lọc theo: ", style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _currentFilter,
                  items: [
                    DropdownMenuItem(
                      value: "Phổ biến",
                      child: Text("Phổ biến"), // 인기순
                    ),
                    DropdownMenuItem(
                      value: "Nhiều đánh giá",
                      child: Text("Nhiều đánh giá"), // 리뷰 많은 순
                    ),
                    DropdownMenuItem(
                      value: "Mới nhất",
                      child: Text("Mới nhất"), // 최신 등록 순
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _applyFilter(value);
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // 상품 그리드
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return GestureDetector(
                  onTap: () {
                    // 클릭 이벤트 - 필요한 경우 처리
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(product['name']!,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(product['price']!,
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
