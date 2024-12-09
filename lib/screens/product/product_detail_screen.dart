import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/grade_utils.dart';
import '../product/ingredient_analysis_screen.dart';
import '../review/add_review_screen.dart';
import '../review/review_detail_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({required this.productId, Key? key}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _productData;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    final productDoc = await _firestore.collection('products').doc(widget.productId).get();
    if (productDoc.exists) {
      setState(() {
        _productData = productDoc.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Chi tiết sản phẩm"',
            style: GoogleFonts.roboto(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: _productData == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      _productData?['imageUrl'] ?? 'https://via.placeholder.com/400',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _productData?['name'] ?? '상품 이름 없음',
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _productData?['description'] ?? '상품 설명 없음',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                '평균 평점',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(double.tryParse(_productData?['averageRating']?.toString() ?? '0') ?? 0).toStringAsFixed(1)}',
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '리뷰 수',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_productData?['reviewCount'] ?? 0}개',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
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
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IngredientAnalysisScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.science),
                        label: Text(
                          'Xem thành phần',
                          style: GoogleFonts.notoSans(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo,
                          elevation: 0,
                          side: const BorderSide(color: Colors.indigo),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddReviewScreen(
                                productId: widget.productId,
                                productName: _productData?['name'] ?? '',
                                productImage: _productData?['imageUrl'] ?? '',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,  // 아이콘 색상을 흰색으로 설정
                        ),
                        label: Text(
                          'Viết đánh giá',
                          style: GoogleFonts.notoSans(
                            color: Colors.white,  // 텍스트 색상을 흰색으로 설정
                            fontWeight: FontWeight.w500,  // 약간의 두께 추가
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '리뷰',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // 전체 리뷰 보기 화면으로 이동
                      },
                      child: Text(
                        '전체보기',
                        style: GoogleFonts.roboto(
                          color: Colors.indigo,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('reviews')
                    .where('productId', isEqualTo: widget.productId)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  print('Connection state: ${snapshot.connectionState}');
                  print('Has data: ${snapshot.hasData}');
                  if (snapshot.hasData) {
                    print('Documents count: ${snapshot.data!.docs.length}');
                    print('ProductId being queried: ${widget.productId}');
                  }

                  if (snapshot.hasError) {
                    print('Stream error: ${snapshot.error}');
                    return Center(
                      child: Text(
                        '데이터를 불러오는데 실패했습니다.',
                        style: GoogleFonts.roboto(color: Colors.red),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '리뷰를 불러오는 중입니다...',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final reviews = snapshot.data!.docs;

                  if (reviews.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '첫 번째 리뷰를 작성해보세요!',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final review = reviews[index].data() as Map<String, dynamic>;
                      final createdAt = review['createdAt'] as Timestamp?;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(review['userId'])
                            .get(),
                        builder: (context, userSnapshot) {
                          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 상품 정보 섹션
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // 패딩 줄임
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple[50], // 그라데이션 대신 깔끔한 단색
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect( // Container 대신 ClipRRect 사용
                                        borderRadius: BorderRadius.circular(6), // 라운드 값 줄임
                                        child: Image.network(
                                          _productData?['imageUrl'] ?? '',
                                          width: 32, // 크기 줄임
                                          height: 32, // 크기 줄임
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _productData?['name'] ?? '',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 13, // 폰트 크기 줄임
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[800], // 색상 톤 조정
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 유저 정보 섹션
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border: Border(
                                      top: BorderSide(
                                        color: Colors.grey.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: Colors.indigo.withOpacity(0.1),
                                            backgroundImage: (userData != null &&
                                                userData['profileImageUrl'] != null &&
                                                userData['profileImageUrl'].toString().isNotEmpty)
                                                ? NetworkImage(userData['profileImageUrl'])
                                                : null,
                                            child: (userData == null ||
                                                userData['profileImageUrl'] == null ||
                                                userData['profileImageUrl'].toString().isEmpty)
                                                ? (userData?['icon'] != null)
                                                ? Text(
                                              userData!['icon'],
                                              style: const TextStyle(fontSize: 24),
                                            )
                                                : Icon(
                                              Icons.person_outline_rounded,
                                              size: 28,
                                              color: Colors.indigo[400],
                                            )
                                                : null,
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                getGradeIcon(userData?['grade']),
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  userData?['username'] ?? 'Người dùng ẩn danh',
                                                  style: GoogleFonts.notoSans(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: [
                                                if (userData?['skinType'] != null)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.indigo.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      userData!['skinType'],
                                                      style: GoogleFonts.notoSans(
                                                        fontSize: 12,
                                                        color: Colors.indigo,
                                                      ),
                                                    ),
                                                  ),
                                                if (userData?['skinConditions'] != null)
                                                  ...(userData!['skinConditions'] as List).map(
                                                        (condition) => Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.teal.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        condition,
                                                        style: GoogleFonts.notoSans(
                                                          fontSize: 12,
                                                          color: Colors.teal,
                                                        ),
                                                      ),
                                                    ),
                                                  ).toList(),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: List.generate(
                                                5,
                                                    (index) => Icon(
                                                  index < (review['rating'] ?? 0)
                                                      ? Icons.star_rounded
                                                      : Icons.star_outline_rounded,
                                                  color: Colors.amber[400],
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (createdAt != null)
                                        Text(
                                          createdAt.toDate().toString().split(' ')[0],
                                          style: GoogleFonts.notoSans(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // 리뷰 내용 섹션 (기존과 동일)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review['title'] ?? '',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        review['content'] ?? '',
                                        style: GoogleFonts.notoSans(
                                          fontSize: 14,
                                          height: 1.5,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if ((review['photoUrls'] as List?)?.isNotEmpty ?? false) ...[
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: (review['photoUrls'] as List).length,
                                            itemBuilder: (context, photoIndex) {
                                              return Container(
                                                margin: const EdgeInsets.only(right: 8),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.08),
                                                      blurRadius: 8,
                                                      spreadRadius: 0,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.network(
                                                    review['photoUrls'][photoIndex],
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        width: 100,
                                                        height: 100,
                                                        color: Colors.grey[200],
                                                        child: Icon(
                                                          Icons.error_outline,
                                                          color: Colors.grey[400],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // 하단 버튼
                                Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Colors.black12),
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReviewDetailScreen(
                                            reviewId: reviews[index].id,
                                          ),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.indigo,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: const BorderRadius.vertical(
                                          bottom: Radius.circular(16),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '자세히 보기',
                                          style: GoogleFonts.notoSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward_ios, size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}