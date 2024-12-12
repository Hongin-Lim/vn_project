
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vn_project/screens/home/recent_reviews_section.dart';

import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/responsive_breakpoints.dart';
import '../auth/user_profile_screen.dart';
import 'category_section.dart';
import 'event_banner.dart';

/// 홈 화면을 구성하는 메인 위젯
/// 배너, 카테고리, 최근 리뷰 섹션으로 구성됨
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  int _currentIndex = 0;
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  /// 사용자 권한 로드
  Future<void> _loadUserRole() async {
    final user = _authService.currentUser;
    if (user != null) {
      final role = await _firestoreService.getUserRole(user.uid);
      setState(() {
        userRole = role;
      });
    }
  }

  /// 로그인되지 않은 경우 스낵바 표시
  void _showLoginRequiredSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Vui lòng đăng nhập để xem hồ sơ',
          style: GoogleFonts.notoSans(),
        ),
        action: SnackBarAction(
          label: 'Đăng nhập',
          onPressed: () => Navigator.pushNamed(context, '/login'),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFfa6386),
      ),
    );
  }

  /// 하단 네비게이션 탭 처리
  void _handleNavigation(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 2) {
      final user = _authService.currentUser;
      if (user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()), // const 제거
        ).then((_) => setState(() => _currentIndex = 0));
      } else {
        _showLoginRequiredSnackBar(context);
        setState(() => _currentIndex = 0);
      }
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktopView = ResponsiveBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(isDesktopView),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // event_banner.dart 파일의 EventBanner 위젯 호출
              EventBanner(size: size),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveBreakpoints.getHorizontalPadding(context),
                ),
                child: _buildMainContent(size, isDesktopView),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// 앱바 구성
  PreferredSizeWidget _buildAppBar(bool isDesktopView) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.white,
      title: Text(
        'Review Này',
        style: GoogleFonts.dancingScript(
          fontSize: isDesktopView ? 36 : 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFfa6386),
        ),
      ),
      actions: [
        if (_authService.currentUser != null)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.deepPurple),
            onPressed: () async {
              await _authService.signOut();
              setState(() {});
            },
          )
        else
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
      ],
    );
  }

  /// 메인 콘텐츠 구성
  Widget _buildMainContent(Size size, bool isDesktopView) {
    final isTabletView = ResponsiveBreakpoints.isTablet(context);

    return Column(
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
        // category section.dart 파일의 CategorySection 위젯 호출
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
        // recent_reviews_section.dart 파일의 RecentReviewsSection 위젯 호출
        RecentReviewsSection(
          firestore: FirebaseFirestore.instance,
          isDesktop: isDesktopView,
          isTablet: isTabletView,
        ),
      ],
    );
  }

  /// 하단 네비게이션 바 구성
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _handleNavigation,
      selectedItemColor: const Color(0xFFfa6386),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Yêu thích'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
      ],
    );
  }
}