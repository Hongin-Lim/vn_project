// lib/screens/product/add_product_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/input_validators.dart';

/// 상품 추가 화면 위젯
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;

  // 디자인 상수
  static const kPrimaryColor = Color(0xFF6B4EFF); // 보라색 계열의 브랜드 컬러
  static const kSecondaryColor = Color(0xFFF5F3FF); // 연한 보라색 배경
  static const kErrorColor = Color(0xFFFF3B3B);
  static const kSuccessColor = Color(0xFF4CAF50);

  /// 카테고리 목록 (베트남어)
  static const List<String> _categories = [
    'Dưỡng da',  // 스킨케어
    'Trang điểm', // 메이크업
    'Tẩy trang',  // 클렌징
    'Khác'        // 기타
  ];

  /// 상품 추가 처리
  Future<void> _handleAddProduct() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final product = Product(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        imageUrl: _imageUrlController.text,
        reviewCount: 0,
        averageRating: 0.0,
      );

      await _firestoreService.addProduct(product);
      _showSuccessMessage();
      Navigator.pop(context);
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 폼 검증
  bool _validateForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return false;

    if (_selectedCategory == null) {
      _showErrorMessage('카테고리를 선택해 주세요');
      return false;
    }

    return true;
  }

  /// 성공 메시지 표시
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Đã thêm sản phẩm thành công',  // 상품이 등록되었습니다
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: kSuccessColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// 에러 메시지 표시
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            message,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: kErrorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        'Thêm sản phẩm',
        style: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: kPrimaryColor,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: kPrimaryColor),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 48, color: kPrimaryColor.withOpacity(0.7)),
                    const SizedBox(height: 8),
                    Text(
                      'Thêm sản phẩm mới (새상품 등록)',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Thông tin cơ bản (기본 정보)'), // 기본 정보
                    const SizedBox(height: 16),
                    _buildNameField(),
                    const SizedBox(height: 20),
                    _buildDescriptionField(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Phân loại (분류)'), // 분류
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Hình ảnh (이미지)'), // 이미지
                    const SizedBox(height: 16),
                    _buildImageUrlField(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildNameField() {
    return _buildInputContainer(
      child: TextFormField(
        controller: _nameController,
        decoration: _buildInputDecoration(
          labelText: 'Tên sản phẩm (상품 이름)',
          hintText: 'Nhập tên sản phẩm',
          prefixIcon: Icons.shopping_bag_outlined,
        ),
        validator: InputValidators.required('상품명을 입력해주세요'),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return _buildInputContainer(
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: _buildInputDecoration(
          labelText: 'Mô tả sản phẩm (상품 설명)',
          hintText: 'Nhập mô tả chi tiết về sản phẩm',
          prefixIcon: Icons.description_outlined,
        ),
        validator: InputValidators.required('상품 설명을 입력해주세요'),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return _buildInputContainer(
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: _buildInputDecoration(
          labelText: 'Danh mục (카테고리)',
          hintText: 'Chọn danh mục sản phẩm',
          prefixIcon: Icons.category_outlined,
        ),
        items: _categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedCategory = value),
        validator: InputValidators.required('카테고리를 선택해주세요'),
      ),
    );
  }

  Widget _buildImageUrlField() {
    return _buildInputContainer(
      child: TextFormField(
        controller: _imageUrlController,
        decoration: _buildInputDecoration(
          labelText: 'URL hình ảnh (상품 이미지 URL)',
          hintText: 'Nhập URL hình ảnh sản phẩm',
          prefixIcon: Icons.image_outlined,
        ),
        validator: InputValidators.url('올바른 이미지 URL을 입력해주세요'),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: kPrimaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kPrimaryColor),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: GoogleFonts.notoSans(color: Colors.grey[600]),
      hintStyle: GoogleFonts.notoSans(color: Colors.grey[400]),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6B4EFF), Color(0xFF9747FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleAddProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          'Thêm sản phẩm',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

}