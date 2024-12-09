import 'dart:typed_data' show Uint8List;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_model.dart';
import '../../models/review.model.dart';

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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  double _rating = 1.0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng đăng nhập để viết đánh giá',
            style: GoogleFonts.notoSans(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _rating < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng điền vào tất cả các trường',
            style: GoogleFonts.notoSans(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      List<String> uploadedPhotoUrls = [];

      if (_selectedImages.isNotEmpty) {
        for (var imageData in _selectedImages) {
          if (imageData['bytes'] != null) {
            try {
              final Uint8List bytes = Uint8List.fromList(imageData['bytes']);
              String fileName =
                  '${DateTime.now().millisecondsSinceEpoch}_${imageData['name']}';

              final storageRef = FirebaseStorage.instance.ref();
              final imageRef = storageRef.child('review_images/$fileName');

              final uploadTask = imageRef.putData(
                bytes,
                SettableMetadata(contentType: 'image/jpeg'),
              );

              uploadTask.snapshotEvents.listen(
                (TaskSnapshot snapshot) {
                  setState(() {
                    _uploadProgress =
                        (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                  });
                },
                onError: (e) {
                  print('Upload error: $e');
                },
              );

              final snapshot = await uploadTask;
              final downloadUrl = await snapshot.ref.getDownloadURL();
              uploadedPhotoUrls.add(downloadUrl);
            } catch (uploadError) {
              print('Error uploading image: $uploadError');
              throw Exception('Tải lên hình ảnh thất bại: $uploadError');
            }
          }
        }
      }

      // Review 모델 생성
      final review = Review(
        productId: widget.productId,
        userId: currentUser.uid,
        title: _titleController.text,
        content: _contentController.text,
        rating: _rating.toInt(),
        photoUrls: uploadedPhotoUrls,
        createdAt: DateTime.now(),
      );

      // Firestore에 리뷰 저장
      final reviewRef =
          await _firestore.collection('reviews').add(review.toFirestore());

      // Product 문서 업데이트 (리뷰 수와 평균 평점)
      final productRef =
          _firestore.collection('products').doc(widget.productId);
      await _firestore.runTransaction((transaction) async {
        final productDoc = await transaction.get(productRef);
        if (!productDoc.exists) {
          throw Exception('Product not found');
        }

        final product = Product.fromFirestore(productDoc);
        final newReviewCount = product.reviewCount + 1;
        final newAverageRating =
            ((product.averageRating * product.reviewCount) + _rating) /
                newReviewCount;

        transaction.update(productRef, {
          'reviewCount': newReviewCount,
          'averageRating': newAverageRating,
        });
      });

      // User 문서 업데이트
      final userRef = _firestore.collection('users').doc(currentUser.uid);
      try {
        // 문서가 존재하는지 먼저 확인
        final userDoc = await userRef.get();
        if (!userDoc.exists) {
          // 문서가 없으면 새로 생성
          await userRef.set({
            'likedReviews': [reviewRef.id],
            'uid': currentUser.uid,
            // 필요한 다른 사용자 정보도 추가
            'email': currentUser.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          // 문서가 있으면 업데이트
          await userRef.update({
            'likedReviews': FieldValue.arrayUnion([reviewRef.id]),
          });
        }
      } catch (e) {
        print('Error updating user document: $e');
        // 에러 처리
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đánh giá đã được gửi thành công',
            style: GoogleFonts.notoSans(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error in _submitReview: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã xảy ra lỗi khi gửi đánh giá: $e',
            style: GoogleFonts.notoSans(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
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

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.productImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.productName,
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bạn có hài lòng với sản phẩm không?',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
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
                            child: DropdownButton<double>(
                              value: _rating,
                              underline: Container(),
                              items: List.generate(
                                5,
                                (index) => DropdownMenuItem(
                                  value: (index + 1).toDouble(),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      Text(
                                        ' ${index + 1} điểm',
                                        style: GoogleFonts.notoSans(),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tiêu đề đánh giá',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Viết tiêu đề về sản phẩm',
                        hintStyle:
                            GoogleFonts.notoSans(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nội dung đánh giá',
                      style: GoogleFonts.notoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Viết đánh giá chân thực về sản phẩm',
                        hintStyle:
                            GoogleFonts.notoSans(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: _isUploading ? null : _pickImages,
                            child: Container(
                              padding: const EdgeInsets.all(16),
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
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isUploading
                                        ? 'Đang tải lên...'
                                        : 'Thêm ảnh',
                                    style: GoogleFonts.notoSans(
                                      color: _isUploading
                                          ? Colors.grey[400]
                                          : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildImagePreview(),
                          ],
                          if (_isUploading && _uploadProgress > 0) ...[
                            const SizedBox(height: 16),
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
                                fontSize: 12,
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
          padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _isUploading ? 'Đang tải lên...' : 'Gửi đánh giá',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
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
