// lib/screens/product/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'widgets/product_action_buttons.dart';
import 'widgets/product_info_section.dart';
import 'widgets/product_review_section.dart';

/// 상품 상세 정보 화면
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    required this.productId,
    Key? key,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  Product? _product;
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// 초기 데이터 로드
  Future<void> _initialize() async {
    await Future.wait([
      _loadProductData(),
      _checkAdminStatus(),
    ]);
  }
  /// 상품 데이터 로드
  Future<void> _loadProductData() async {
    try {
      setState(() => _isLoading = true);
      final product = await _firestoreService.getProductById(widget.productId);
      setState(() => _product = product);
    } catch (e) {
      _showErrorMessage('상품 정보 로드 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 에러 메시지 표시
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.notoSans()),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
          ? _buildErrorView()
          : _buildContent(),
    );
  }

  /// 앱바 구성
  @override
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        'Chi tiết sản phẩm',
        style: GoogleFonts.notoSans(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_isAdmin) ...[
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _showDeleteDialog,
          ),
        ],
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.black87),
          onPressed: () {}, // TODO: 공유 기능 구현
        ),
      ],
    );
  }

  /// 에러 화면 구성
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '상품 정보를 불러올 수 없습니다',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _loadProductData,
            child: Text(
              '다시 시도',
              style: GoogleFonts.notoSans(
                color: Colors.indigo,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 메인 콘텐츠 구성
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(),
          ProductInfoSection(product: _product!),
          ProductActionButtons(
            productId: widget.productId,
            productName: _product!.name,
            productImage: _product!.imageUrl,
          ),
          ProductReviewSection(productId: widget.productId),
        ],
      ),
    );
  }

  /// 상품 이미지 구성
  Widget _buildProductImage() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        image: DecorationImage(
          image: NetworkImage(_product!.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
  /// 관리자 권한 확인
  Future<void> _checkAdminStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      final isAdmin = await _firestoreService.isAdmin(user.uid);
      setState(() => _isAdmin = isAdmin);
    }
  }

  /// 상품 수정 다이얼로그 표시
  Future<void> _showEditDialog() async {
    final nameController = TextEditingController(text: _product?.name);
    final descriptionController = TextEditingController(text: _product?.description);
    final imageUrlController = TextEditingController(text: _product?.imageUrl);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('상품 정보 수정', style: GoogleFonts.notoSans()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '상품명'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: '설명'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: '이미지 URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소', style: GoogleFonts.notoSans()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
            ),
            child: Text('수정', style: GoogleFonts.notoSans(
              color: Colors.white,
            )),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _firestoreService.updateProduct(
          widget.productId,
          {
            'name': nameController.text,
            'description': descriptionController.text,
            'imageUrl': imageUrlController.text,
          },
        );
        await _loadProductData();  // 데이터 새로고침
        _showSuccessMessage('상품 정보가 수정되었습니다.');
      } catch (e) {
        _showErrorMessage(e.toString());
      }
    }

    nameController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
  }

  /// 상품 삭제 확인 다이얼로그 표시
  Future<void> _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('상품 삭제', style: GoogleFonts.notoSans()),
        content: Text(
          '이 상품을 정말 삭제하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소', style: GoogleFonts.notoSans()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('삭제', style: GoogleFonts.notoSans(
              color: Colors.white,
            )
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _firestoreService.deleteProduct(widget.productId);
        _showSuccessMessage('상품이 삭제되었습니다.');
        Navigator.pop(context);  // 화면 닫기
      } catch (e) {
        _showErrorMessage(e.toString());
      }
    }
  }

  /// 성공 메시지 표시
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.notoSans()),
        backgroundColor: Colors.green,
      ),
    );
  }

}