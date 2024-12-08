import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vn_project/screens/product/add_product_screen.dart';
import 'package:vn_project/screens/review/review_detail_screen.dart';

import '../backup/product_list_screen_backup.dart';

// 반응형 유틸리티 클래스
class ResponsiveBreakpoints {
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 1200;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
          MediaQuery.of(context).size.width <= 1200;
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return MediaQuery.of(context).size.width * 0.1;
    if (isTablet(context)) return 32.0;
    return 16.0;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _currentIndex = 0;
  User? _user;
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        _getUserRole(user.uid);
      });
    }
  }

  void _getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          userRole = userDoc['role'];
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktopView = ResponsiveBreakpoints.isDesktop(context);
    final isTabletView = ResponsiveBreakpoints.isTablet(context);

    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
        elevation: 0,
        title: Text(
        'Review Này',
        style: GoogleFonts.roboto(
        fontSize: isDesktopView ? 28 : 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
    ),
    ),
    backgroundColor: Colors.white,
    actions: [
    if (_auth.currentUser != null)
    IconButton(
    icon: const Icon(Icons.logout, color: Colors.deepPurple),
    onPressed: () async {
    await _auth.signOut();
    setState(() {});
    },
    )
    else
    Row(
    children: [
    TextButton(
    onPressed: () => Navigator.pushNamed(context, '/login'),
    child: Text(
    'Login',
    style: GoogleFonts.notoSans(
    color: Colors.deepPurple,
    fontWeight: FontWeight.bold,
    fontSize: isDesktopView ? 16 : 14,
    ),
    ),
    ),
    TextButton(
    onPressed: () => Navigator.pushNamed(context, '/signup'),
    child: Text(
    'Sign Up',
    style: GoogleFonts.notoSans(
    color: Colors.deepPurple,
    fontWeight: FontWeight.bold,
    fontSize: isDesktopView ? 16 : 14,
    ),
    ),
    ),
    ],
    ),
    ],
    ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventBanner(size: size),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveBreakpoints.getHorizontalPadding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Danh mục',
                      style: GoogleFonts.roboto(
                        fontSize: isDesktopView ? 28 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CategorySection(size: size),
                    const SizedBox(height: 32),
                    Text(
                      'Đánh giá gần đây',
                      style: GoogleFonts.roboto(
                        fontSize: isDesktopView ? 28 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RecentReviewsSection(
                      firestore: _firestore,
                      isDesktop: isDesktopView,
                      isTablet: isTabletView,
                    ),
                    if (userRole == 'admin')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddProductScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: Size(
                              isDesktopView ? size.width * 0.2 : double.infinity,
                              50,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '상품 등록',
                                style: GoogleFonts.notoSans(
                                  fontSize: isDesktopView ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Yêu thích'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
class EventBanner extends StatefulWidget {
  final Size size;

  const EventBanner({required this.size, Key? key}) : super(key: key);

  @override
  State<EventBanner> createState() => _EventBannerState();
}

class _EventBannerState extends State<EventBanner> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const List<String> bannerImages = [
      'https://hongin-lim.github.io/vn_project/images/slide-001.png',
      'https://hongin-lim.github.io/vn_project/images/slide-002.png',
    ];

    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    double bannerHeight = isDesktop
        ? 500
        : MediaQuery.of(context).size.width * 9 / 16;

    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bannerImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // 배너 클릭 시 동작 추가 가능
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                  child: Stack(
                    children: [
                      Image.network(
                        bannerImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bannerImages.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  entry.key,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == entry.key
                      ? Colors.deepPurple
                      : Colors.deepPurple.withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
class CategorySection extends StatelessWidget {
  final Size size;

  const CategorySection({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

    final List<Map<String, dynamic>> categories = [
      {'name': 'Tất cả', 'icon': Icons.all_inclusive, 'color': Colors.purple[800]},
      {'name': 'Dưỡng da', 'icon': Icons.spa, 'color': Colors.pink[400]},
      {'name': 'Trang điểm', 'icon': Icons.brush, 'color': Colors.orange[400]},
      {'name': 'Tẩy trang', 'icon': Icons.face, 'color': Colors.blue[400]},
      {'name': 'Khác', 'icon': Icons.category, 'color': Colors.green[400]},
    ];

    if (isDesktop || isTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 5 : 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) => _buildCategoryItem(
          context,
          categories[index],
          isDesktop,
        ),
      );
    }

    return SizedBox(
      height: size.height * 0.15,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) => _buildCategoryItem(
          context,
          categories[index],
          false,
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Map<String, dynamic> category, bool isDesktop) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductListScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 16 : 12),
                decoration: BoxDecoration(
                  color: category['color'],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category['icon'] as IconData,
                  size: isDesktop ? 32 : 24,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              Text(
                category['name'] as String,
                style: GoogleFonts.notoSans(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class RecentReviewsSection extends StatelessWidget {
  final FirebaseFirestore firestore;
  final bool isDesktop;
  final bool isTablet;

  const RecentReviewsSection({
    Key? key,
    required this.firestore,
    required this.isDesktop,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .limit(isDesktop ? 6 : 4)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Không có đánh giá nào.',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final reviews = snapshot.data!.docs;

        if (isDesktop || isTablet) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 2,
              childAspectRatio: isDesktop ? 1.2 : 1.1,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: reviews.length,
            itemBuilder: (context, index) => _buildReviewCard(
              context,
              reviews[index],
              true,
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            final productId = review['productId'];

            return FutureBuilder<DocumentSnapshot>(
              future: firestore.collection('products').doc(productId).get(),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerCard();
                }

                if (productSnapshot.hasError || !productSnapshot.hasData) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        '상품 정보를 불러오는 데 실패했습니다.',
                        style: GoogleFonts.notoSans(color: Colors.red[400]),
                      ),
                    ),
                  );
                }

                final product = productSnapshot.data!;
                final productName = product['name'];

                return _buildReviewCard(context, review, false, productName: productName);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, __) => _buildShimmerCard(),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: 200,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, DocumentSnapshot review, bool isGrid, {String? productName}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewDetailScreen(
                reviewId: review.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple[100],
                    child: const Icon(Icons.person, color: Colors.deepPurple),
                    radius: isDesktop ? 24 : 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (productName != null)
                          Text(
                            productName,
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.bold,
                              fontSize: isDesktop ? 18 : 16,
                              color: Colors.deepPurple,
                            ),
                          ),
                        Text(
                          review['title'] ?? '',
                          style: GoogleFonts.notoSans(
                            fontWeight: FontWeight.w500,
                            fontSize: isDesktop ? 16 : 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RatingBar.builder(
                initialRating: (review['rating'] ?? 0).toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: isDesktop ? 20 : 16,
                ignoreGestures: true,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {},
              ),
              const SizedBox(height: 12),
              Text(
                review['content'] ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                  fontSize: isDesktop ? 14 : 12,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}