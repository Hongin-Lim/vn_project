// lib/screens/product/product_list_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

/// 상품 목록 화면
/// 카테고리별 상품을 보여주고 검색과 필터링 기능을 제공합니다.
class ProductListScreen extends StatefulWidget {
  final String? category;

  const ProductListScreen({Key? key, this.category}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = "";
  String _currentFilter = "Phổ biến";
  bool _isLoading = false;
  String _userRole = '';
  bool _isAdmin = false;  // 관리자 상태 추가
  static const _pageSize = 20;
  Product? _lastProduct;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// 초기 데이터 로드 및 권한 체크
  Future<void> _initialize() async {
    await Future.wait([
      _loadProducts(),
      _checkAdminStatus(),
    ]);
  }

  /// 관리자 권한 확인
  Future<void> _checkAdminStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      final isAdmin = await _firestoreService.isAdmin(user.uid);
      setState(() => _isAdmin = isAdmin);
    }
  }

  /// 상품 목록 로드
  Future<void> _loadProducts() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final newProducts = await _firestoreService.getProducts(
        category: widget.category,
        lastProduct: _lastProduct,
        limit: _pageSize,
      );

      setState(() {
        _lastProduct = newProducts.isEmpty ? null : newProducts.last;
        _products.addAll(newProducts);
        _applyFilters();
      });
    } catch (e) {
      _showErrorMessage('상품 로드 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 검색어 적용
  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  /// 정렬 필터 적용
  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _applyFilters();
    });
  }

  /// 필터와 검색어 모두 적용
  void _applyFilters() {
    var filtered = _products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    switch (_currentFilter) {
      case "Phổ biến":
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case "Nhiều đánh giá":
        filtered.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case "Mới nhất":
      // 이미 시간순 정렬되어 있으므로 별도 처리 불필요
        break;
    }

    setState(() => _filteredProducts = filtered);
  }

  /// 에러 메시지 표시
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

  /// 앱바 구성
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        widget.category ?? '상품 목록',
        style: GoogleFonts.notoSans(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.filter_alt_outlined, color: Colors.black87),
          onPressed: () {}, // TODO: 필터 기능 구현
        ),
      ],
    );
  }

  /// 본문 구성
  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterBar(),
        Expanded(
          child: _filteredProducts.isEmpty
              ? _buildEmptyState()
              : _buildProductGrid(),
        ),
        if (_isLoading) _buildLoadingIndicator(),
        if (_lastProduct != null) _buildLoadMoreButton(),
      ],
    );
  }

  /// 검색바 구성
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: '상품 검색...',
          hintStyle: GoogleFonts.notoSans(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
        ),
        onChanged: _filterProducts,
      ),
    );
  }

  /// 필터바 구성
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            "정렬: ",
            style: GoogleFonts.notoSans(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          _buildFilterDropdown(),
          const Spacer(),
          if (_isAdmin) _buildAddProductButton(),  // _userRole 대신 _isAdmin 사용
        ],
      ),
    );
  }

  /// 필터 드롭다운
  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: _currentFilter,
      items: ["Phổ biến", "Nhiều đánh giá", "Mới nhất"].map((filter) {
        return DropdownMenuItem(
          value: filter,
          child: Text(filter, style: GoogleFonts.notoSans()),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) _applyFilter(value);
      },
      underline: const SizedBox(),
    );
  }

  /// 상품 추가 버튼
  Widget _buildAddProductButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddProductScreen()),
        );
        if (result == true) {
          // 상품이 추가되면 목록 새로고침
          await _loadProducts();
        }
      },
      icon: const Icon(
        Icons.add,
        size: 18,
        color: Colors.white,
      ),
      label: Text(
        '상품 등록',
        style: GoogleFonts.notoSans(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 상품 그리드 구성
  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) => _buildProductCard(_filteredProducts[index]),
    );
  }

  /// 상품 카드 구성
  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(productId: product.id!),
        ),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product.imageUrl),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 브랜드명 추가
                  Text(
                    product.brand,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
// 해시태그 목록 추가
                  if (product.hashtags.isNotEmpty)
                    SizedBox(
                      height: 22,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: product.hashtags.length > 3 ? 3 : product.hashtags.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 6),
                        itemBuilder: (context, index) {
                          final isLast = index == 2 && product.hashtags.length > 2; // 최대 2개까지만 표시

                          // 파스텔톤 색상 배열
                          final List<Color> tagColors = [
                            const Color(0xFFE8F3FF),  // 연한 하늘색
                            const Color(0xFFFFE8F3),  // 연한 분홍색
                            const Color(0xFFF3E8FF),  // 연한 보라색

                          ];

                          final List<Color> textColors = [
                            const Color(0xFF4A91F5),  // 하늘색 텍스트
                            const Color(0xFFFF478A),  // 분홍색 텍스트
                            const Color(0xFF9747FF),  // 보라색 텍스트

                          ];

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isLast ? const Color(0xFFF5F6F8) : tagColors[index % tagColors.length],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isLast
                                  ? '+${product.hashtags.length - 2}'
                                  : '#${product.hashtags[index]}',
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                height: 1.2,
                                color: isLast ? const Color(0xFF8E94A0) : textColors[index % textColors.length],
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${product.reviewCount}bài Review',
                        style: GoogleFonts.notoSans(
                          fontSize: 13,
                          color: Colors.grey[600],
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
  }

  /// 상품 이미지 구성
  Widget _buildProductImage(String imageUrl) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 50,  // 높이 증가
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),  // 투명도 증가
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 빈 상태 표시
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '상품이 없습니다.',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 인디케이터
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      ),
    );
  }

  /// 더보기 버튼
  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: TextButton(
          onPressed: _loadProducts,
          child: Text(
            '더 보기',
            style: GoogleFonts.notoSans(
              fontWeight: FontWeight.w500,
              color: Colors.deepPurple,
            ),
          ),
        ),
      ),
    );
  }
}