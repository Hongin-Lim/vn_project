import 'dart:typed_data' show Uint8List;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// 리뷰 작성 화면 위젯
class AddReviewScreen extends StatefulWidget {
  final String productId; // 상품 ID
  final String productName; // 상품 이름
  final String productImage; // 상품 이미지 URL

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
  // 텍스트 입력을 관리하는 컨트롤러들
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  double _rating = 1.0; // 별점 (기본값 1점)

  // Firebase 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 선택된 이미지들을 저장하는 리스트
  List<Map<String, dynamic>> _selectedImages = [];
  bool _isUploading = false; // 업로드 진행 중 여부
  double _uploadProgress = 0.0; // 업로드 진행률

  /// 이미지 선택 메서드
  Future<void> _pickImages() async {
    try {
      // FilePicker를 사용하여 이미지 선택
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, // 다중 선택 허용
        type: FileType.image, // 이미지 파일만 선택 가능
        withData: true, // 파일 데이터를 메모리에 로드
        allowCompression: true, // 압축 허용
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.bytes != null) {
              // 파일 크기 체크 (5MB 제한)
              if (file.bytes!.length > 5 * 1024 * 1024) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('파일 크기는 5MB 이하여야 합니다.')),
                );
                continue;
              }
              // 선택된 이미지 정보 저장
              _selectedImages.add(
                  {'bytes': file.bytes, 'name': file.name, 'previewUrl': null});
            }
          }
        });
      }
    } catch (e) {
      print('Pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미지 선택 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 리뷰 제출 메서드
  Future<void> _submitReview() async {
    // 입력값 검증
    if (_titleController.text.isEmpty ||
        _contentController.text.isEmpty ||
        _rating < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 필드를 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 업로드 상태 변경
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      List<String> uploadedPhotoUrls = [];

      // 이미지 업로드
      if (_selectedImages.isNotEmpty) {
        for (var imageData in _selectedImages) {
          if (imageData['bytes'] != null) {
            try {
              // 바이트 데이터를 Uint8List로 변환
              final Uint8List bytes = Uint8List.fromList(imageData['bytes']);
              String fileName =
                  '${DateTime.now().millisecondsSinceEpoch}_${imageData['name']}';

              // Firebase Storage 레퍼런스 생성
              final storageRef = FirebaseStorage.instance.ref();
              final imageRef = storageRef.child('review_images/$fileName');

              // 업로드 태스크 생성 및 실행
              final uploadTask = imageRef.putData(
                bytes,
                SettableMetadata(contentType: 'image/jpeg'),
              );

              // 업로드 진행 상황 모니터링
              uploadTask.snapshotEvents.listen(
                (TaskSnapshot snapshot) {
                  setState(() {
                    _uploadProgress =
                        (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                  });
                  print(
                      'Upload progress: ${_uploadProgress.toStringAsFixed(2)}%');
                },
                onError: (e) {
                  print('Upload error: $e');
                },
              );

              // 업로드 완료 대기
              final snapshot = await uploadTask;

              // 업로드된 파일의 다운로드 URL 가져오기
              final downloadUrl = await snapshot.ref.getDownloadURL();
              uploadedPhotoUrls.add(downloadUrl);

              print('Upload complete: $downloadUrl');
            } catch (uploadError) {
              print('Error uploading image: $uploadError');
              throw Exception('이미지 업로드 실패: $uploadError');
            }
          }
        }
      }

      // Firestore에 리뷰 데이터 저장
      await _firestore.collection('reviews').add({
        'productId': widget.productId,
        'userId': 'sample_user_id',
        'title': _titleController.text,
        'content': _contentController.text,
        'rating': _rating,
        'photoUrls': uploadedPhotoUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('리뷰가 작성되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error in _submitReview: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('리뷰 작성 중 오류가 발생했습니다: $e'),
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

  /// 이미지 프리뷰를 생성하는 위젯
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
              // 이미지 표시
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
              // 삭제 버튼
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '리뷰 작성',
          style: TextStyle(
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
            // 상품 정보 섹션
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                  // 별점 선택 UI
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '상품은 만족하셨나요?',
                          style: TextStyle(
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
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    Text(' ${index + 1}점'),
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

                  // 제목 입력
                  const Text(
                    '리뷰 제목',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: '상품에 대한 제목을 작성해주세요',
                      hintStyle: TextStyle(color: Colors.grey[400]),
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

                  // 내용 입력
                  const Text(
                    '리뷰 내용',
                    style: TextStyle(
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
                      hintText: '상품에 대한 솔직한 리뷰를 작성해주세요',
                      hintStyle: TextStyle(color: Colors.grey[400]),
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

                  // 이미지 업로드 섹션
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
                              border: Border.all(
                                color: Colors.grey[300]!,
                              ),
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
                                  _isUploading ? '업로드 중...' : '사진 추가하기',
                                  style: TextStyle(
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
                            '업로드 중: ${_uploadProgress.toStringAsFixed(1)}%',
                            style: TextStyle(
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
              _isUploading ? '업로드 중...' : '리뷰 등록하기',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
