// lib/screens/home/event_banner.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/responsive_breakpoints.dart';

/// 홈 화면 상단의 이벤트 배너를 표시하는 위젯
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

  // 배너 이미지 URL 목록
  static const List<String> bannerImages = [
    'https://hongin-lim.github.io/vn_project/images/slide-004.jpg',
    'https://hongin-lim.github.io/vn_project/images/slide-006.jpg',
    'https://hongin-lim.github.io/vn_project/images/slide-002.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  /// 자동 슬라이드 시작
  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < bannerImages.length - 1) {
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
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    double bannerHeight = isDesktop ? 500 : MediaQuery.of(context).size.width * 9 / 16;

    return Column(
      children: [
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bannerImages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _buildBannerItem(bannerImages[index]),
          ),
        ),
        const SizedBox(height: 16),
        _buildPageIndicators(),
      ],
    );
  }

  /// 배너 아이템 구성
  Widget _buildBannerItem(String imageUrl) {
    return GestureDetector(
      onTap: () {
        // 배너 클릭 이벤트 처리
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.grey),
        child: Stack(
          children: [
            _buildBannerImage(imageUrl),
            _buildGradientOverlay(),
          ],
        ),
      ),
    );
  }

  /// 배너 이미지 로드
  Widget _buildBannerImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white),
        );
      },
    );
  }

  /// 그라데이션 오버레이
  Widget _buildGradientOverlay() {
    return Container(
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
    );
  }

  /// 페이지 인디케이터 구성
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: bannerImages.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => _pageController.animateToPage(
            entry.key,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ),
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
    );
  }
}