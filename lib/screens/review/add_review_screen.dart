// 이것도 일단 안씀
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/review.model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class AddReviewScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String productImage;

  const AddReviewScreen({
    required this.productId,
    required this.productName,
    required this.productImage,
    Key? key,
  }) : super(key: key);

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  double _rating = 1.0;

  List<Map<String, dynamic>> _selectedImages = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
        allowCompression: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.bytes != null) {
              if (file.bytes!.length > 5 * 1024 * 1024) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Kích thước tệp phải nhỏ hơn 5MB',
                      style: GoogleFonts.notoSans(),
                    ),
                  ),
                );
                continue;
              }
              _selectedImages.add(
                  {'bytes': file.bytes, 'name': file.name, 'previewUrl': null});
            }
          }
        });
      }
    } catch (e) {
      print('Pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã xảy ra lỗi khi chọn hình ảnh',
            style: GoogleFonts.notoSans(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitReview() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showErrorMessage('Vui lòng đăng nhập để viết đánh giá');
      return;
    }

    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      _showErrorMessage('Vui lòng điền vào tất cả các trường');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Review 모델 생성
      final review = Review(
        productId: widget.productId,
        userId: currentUser.uid,
        title: _titleController.text,
        content: _contentController.text,
        rating: _rating.toInt(),
        photoUrls: [], // 빈 배열로 시작
        createdAt: DateTime.now(),
      );

      // 이미지 데이터 변환 (Uint8List를 String 경로로 변환하는 로직 필요)
      final photoPaths = _selectedImages.map((img) => img['name'] as String).toList();

      // FirestoreService 호출 (파라미터 순서 맞춤)
      await _firestoreService.addReview(
          widget.productId,  // productId 먼저
          review,           // review 객체
          photoPaths        // 이미지 경로 리스트
      );

      _showSuccessMessage('Đánh giá đã được gửi thành công');
      Navigator.pop(context);
    } catch (e) {
      _showErrorMessage('Đã xảy ra lỗi khi gửi đánh giá: $e');
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSans(),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSans(),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImages.isEmpty) return Container();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _selectedImages[index]['bytes'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedImages.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
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

// 전체화면 레이아웃 수정
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.notoSansTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Viết đánh giá',
            style: GoogleFonts.notoSans(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.productImage,
                        width: isSmallScreen ? 50 : 60,
                        height: isSmallScreen ? 50 : 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: isSmallScreen ? 50 : 60,
                            height: isSmallScreen ? 50 : 60,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: isSmallScreen ? 20 : 24,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    Expanded(
                      child: Text(
                        widget.productName,
                        style: GoogleFonts.notoSans(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Wrap(  // Row 대신 Wrap을 사용하여 유연한 레이아웃 구현
                        alignment: WrapAlignment.center,
                        spacing: 12.0,  // 아이템 간 가로 간격
                        runSpacing: 12.0,  // 줄 바꿈 시 세로 간격
                        children: [
                          Text(
                            'Bạn có hài lòng với sản phẩm không?',
                            style: GoogleFonts.notoSans(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<double>(
                                value: _rating,
                                isDense: true,
                                itemHeight: 48,  // 드롭다운 아이템 높이 설정
                                items: List.generate(
                                  5,
                                      (index) => DropdownMenuItem(
                                    value: (index + 1).toDouble(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        Text(
                                          ' ${index + 1} điểm',
                                          style: GoogleFonts.notoSans(
                                            fontSize: isSmallScreen ? 13 : 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _rating = value ?? 1.0;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 24),
                    Text(
                      'Tiêu đề đánh giá',
                      style: GoogleFonts.notoSans(
                        fontSize: isSmallScreen ? 14 : 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    TextField(
                      controller: _titleController,
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      decoration: InputDecoration(
                        hintText: 'Viết tiêu đề về sản phẩm',
                        hintStyle: GoogleFonts.notoSans(
                          color: Colors.grey[400],
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 24),
                    Text(
                      'Nội dung đánh giá',
                      style: GoogleFonts.notoSans(
                        fontSize: isSmallScreen ? 14 : 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    TextField(
                      controller: _contentController,
                      maxLines: 6,
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      decoration: InputDecoration(
                        hintText: 'Viết đánh giá chân thực về sản phẩm',
                        hintStyle: GoogleFonts.notoSans(
                          color: Colors.grey[400],
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 24),
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: _isUploading ? null : _pickImages,
                            child: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color: _isUploading
                                        ? Colors.grey[400]
                                        : Colors.grey,
                                    size: isSmallScreen ? 20 : 24,
                                  ),
                                  SizedBox(width: isSmallScreen ? 6 : 8),
                                  Text(
                                    _isUploading ? 'Đang tải lên...' : 'Thêm ảnh',
                                    style: GoogleFonts.notoSans(
                                      color: _isUploading
                                          ? Colors.grey[400]
                                          : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_selectedImages.isNotEmpty) ...[
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            _buildImagePreview(),
                          ],
                          if (_isUploading && _uploadProgress > 0) ...[
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            LinearProgressIndicator(
                              value: _uploadProgress / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.indigo),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Đang tải lên: ${_uploadProgress.toStringAsFixed(1)}%',
                              style: GoogleFonts.notoSans(
                                color: Colors.grey[600],
                                fontSize: isSmallScreen ? 11 : 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _isUploading ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                disabledBackgroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 12 : 16
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _isUploading ? 'Đang tải lên...' : 'Gửi đánh giá',
                style: GoogleFonts.notoSans(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
