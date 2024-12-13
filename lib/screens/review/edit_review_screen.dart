// lib/screens/review/edit_review_screen.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/review.model.dart';
import '../../services/firestore_service.dart';

class EditReviewScreen extends StatefulWidget {
  final String reviewId;

  const EditReviewScreen({
    required this.reviewId,
    Key? key,
  }) : super(key: key);

  @override
  _EditReviewScreenState createState() => _EditReviewScreenState();
}

class _EditReviewScreenState extends State<EditReviewScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _firestoreService = FirestoreService();

  double _rating = 1.0;
  List<Map<String, dynamic>> _selectedImages = [];
  List<String> _existingPhotos = [];
  bool _isLoading = false;
  Review? _originalReview;

  @override
  void initState() {
    super.initState();
    _loadReviewData();
  }

  Future<void> _loadReviewData() async {
    setState(() => _isLoading = true);
    try {
      final review = await _firestoreService.getReview(widget.reviewId);
      if (review != null) {
        setState(() {
          _originalReview = review;
          _titleController.text = review.title;
          _contentController.text = review.content;
          _rating = review.rating.toDouble();
          _existingPhotos = List.from(review.photoUrls);
        });
      }
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.bytes != null) {
              if (file.bytes!.length > 5 * 1024 * 1024) {
                _showErrorMessage('이미지 크기는 5MB를 초과할 수 없습니다');
                continue;
              }
              _selectedImages.add({
                'bytes': file.bytes,
                'name': file.name,
              });
            }
          }
        });
      }
    } catch (e) {
      _showErrorMessage('이미지 선택 중 오류가 발생했습니다');
    }
  }

  Future<void> _handleSubmit() async {
    if (_originalReview == null) return;
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      _showErrorMessage('모든 필드를 입력해주세요');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedReview = _originalReview!.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        rating: _rating.toInt(),
        photoUrls: _existingPhotos,
      );

      // 새로 선택된 이미지들의 경로 준비
      final photoPaths = _selectedImages.map((img) => img['name'] as String).toList();

      await _firestoreService.updateReview(widget.reviewId, updatedReview, photoPaths);

      Navigator.pop(context, true); // true를 반환하여 수정 완료를 알림
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeExistingPhoto(int index) {
    setState(() {
      _existingPhotos.removeAt(index);
    });
  }

  void _removeNewPhoto(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.notoSans()),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _originalReview == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Chỉnh sửa đánh giá',
          style: GoogleFonts.notoSans(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRatingSection(),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildContentField(),
              const SizedBox(height: 16),
              _buildPhotoSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildRatingSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '평점',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _rating,
            min: 1,
            max: 5,
            divisions: 4,
            label: _rating.toStringAsFixed(1),
            onChanged: (value) => setState(() => _rating = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1점', style: GoogleFonts.notoSans()),
              Text('5점', style: GoogleFonts.notoSans()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: '제목',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: '내용',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사진',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
              color: Colors.black
          ),
        ),
        const SizedBox(height: 8),
        if (_existingPhotos.isNotEmpty) _buildExistingPhotos(),
        if (_selectedImages.isNotEmpty) _buildNewPhotos(),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_photo_alternate),
          label: Text('사진 추가', style: GoogleFonts.notoSans(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingPhotos() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _existingPhotos.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(_existingPhotos[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 12,
                child: GestureDetector(
                  onTap: () => _removeExistingPhoto(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNewPhotos() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: MemoryImage(_selectedImages[index]['bytes']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 12,
                child: GestureDetector(
                  onTap: () => _removeNewPhoto(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _isLoading ? '수정 중...' : '수정 완료',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}