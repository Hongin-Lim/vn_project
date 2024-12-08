import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // 카테고리 드롭다운 값을 관리할 변수
  String? _selectedCategory;

  // 카테고리 목록 (베트남어)
  final List<String> _categories = [
    'Dưỡng da', // 피부 관리
    'Trang điểm', // 메이크업
    'Tẩy trang', // 클렌징, 리무버
    'Khác' // 기타
  ];

  Future<void> _addProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategory == null) {
        // 카테고리가 선택되지 않은 경우 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카테고리를 선택해 주세요')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('products').add({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'imageUrl': _imageUrlController.text,
          'reviewCount': 0, // 초기 리뷰 수는 0
          'averageRating': 0.0, // 초기 평균 평점은 0.0
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('상품이 등록되었습니다.')));
        Navigator.pop(context); // 화면 닫기
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('상품 등록 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // 고급스러운 회색 배경
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.deepPurple[800], // 다크한 퍼플로 고급스러움 강조
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상품명 입력란
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'Enter the product name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              // 상품 설명 입력란
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Product Description',
                  hintText: 'Enter the product description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Product description is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              // 카테고리 드롭다운
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'Select product category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),

              // 이미지 URL 입력란
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'Enter image URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Image URL is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Add Product 버튼
              ElevatedButton(
                onPressed: _addProduct,
                child: Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[800],
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadowColor: Colors.deepPurple[600],
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
