// lib/screens/home/category_section.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/responsive_breakpoints.dart';
import '../product/product_list_screen.dart';

/// 제품 카테고리 섹션을 표시하는 위젯
class CategorySection extends StatelessWidget {
  final Size size;

  const CategorySection({
    Key? key,
    required this.size,
  }) : super(key: key);

  /// 카테고리 데이터 정의
  static final List<Map<String, dynamic>> categories = [
    {
      'name': 'Tất cả',
      'icon': Icons.all_inclusive,
      'color': Colors.purple[800]
    },
    {'name': 'Dưỡng da', 'icon': Icons.spa, 'color': Colors.pink[400]},
    {'name': 'Trang điểm', 'icon': Icons.brush, 'color': Colors.orange[400]},
    {'name': 'Tẩy trang', 'icon': Icons.face, 'color': Colors.blue[400]},
    {'name': 'Khác', 'icon': Icons.category, 'color': Colors.green[400]},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

    if (isDesktop || isTablet) {
      return _buildGrid(context, isDesktop);
    }

    return _buildMobileGrid(context);
  }

  /// 데스크톱/태블릿용 그리드 레이아웃
  Widget _buildGrid(BuildContext context, bool isDesktop) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 5 : 3,
        childAspectRatio: isDesktop ? 1.2 : 1.0,
        crossAxisSpacing: isDesktop ? 16 : 8,
        mainAxisSpacing: isDesktop ? 16 : 8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => _buildCategoryItem(
        context,
        categories[index],
        isDesktop,
      ),
    );
  }

  /// 모바일용 그리드 레이아웃
  Widget _buildMobileGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => _buildCategoryItem(
        context,
        categories[index],
        false,
      ),
    );
  }

  /// 개별 카테고리 아이템 구성
  Widget _buildCategoryItem(
      BuildContext context,
      Map<String, dynamic> category,
      bool isDesktop,
      ) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _onCategoryTap(context, category),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 16 : 8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCategoryIcon(category, isDesktop),
              SizedBox(height: isDesktop ? 12 : 6),
              _buildCategoryName(category, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  /// 카테고리 아이콘 구성
  Widget _buildCategoryIcon(Map<String, dynamic> category, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 10),
      decoration: BoxDecoration(
        color: category['color'],
        shape: BoxShape.circle,
      ),
      child: Icon(
        category['icon'] as IconData,
        size: isDesktop ? 32 : 24,
        color: Colors.white,
      ),
    );
  }

  /// 카테고리 이름 구성
  Widget _buildCategoryName(Map<String, dynamic> category, bool isDesktop) {
    return Container(
      width: double.infinity,
      child: Text(
        category['name'] as String,
        style: GoogleFonts.notoSans(
          fontSize: isDesktop ? 14 : 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  /// 카테고리 탭 이벤트 처리
  void _onCategoryTap(BuildContext context, Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(
          category: category['name'] as String,
        ),
      ),
    );
  }
}