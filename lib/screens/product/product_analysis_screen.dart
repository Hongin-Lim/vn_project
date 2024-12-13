import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IngredientAnalysisScreen extends StatelessWidget {
  final List<Map<String, String>> ingredients = const [
    {
      'name': 'Nước tinh khiết, nước cất, nước',
      'risk': '1',
      'description': 'Mục đích: Dung môi, Chất dưỡng da',
      'tag': 'Dưỡng ẩm da',
    },
    {
      'name': 'Glycerin',
      'risk': '1-2',
      'description': 'Mục đích: Chất dưỡng tóc, Chất dưỡng ẩm, Hương liệu, Chất biến tính, Chất điều chỉnh độ nhớt, Chất bảo vệ da',
      'tag': 'Dưỡng ẩm da, Bảo vệ da',
    },
    {
      'name': 'Sodium Cocoyl Glycinate',
      'risk': '1',
      'description': 'Mục đích: Chất hoạt động bề mặt (Chất tẩy rửa), Chất dưỡng tóc, Chất dưỡng da',
      'tag': 'Dưỡng ẩm da, Làm sạch da',
    },
    {
      'name': 'Sodium Lauroyl Glutamate',
      'risk': '1',
      'description': 'Mục đích: Chất dưỡng tóc, Chất tạo bọt nhẹ nhàng',
      'tag': 'Dưỡng ẩm da, Làm sạch nhẹ nhàng',
    },
    {
      'name': 'Butylene Glycol',
      'risk': '1',
      'description': 'Mục đích: Dung môi, Chất điều chỉnh độ nhớt, Chất dưỡng ẩm da',
      'tag': 'Dưỡng ẩm da, Cân bằng độ ẩm',
    },
    {
      'name': 'Centella Asiatica Extract',
      'risk': '1',
      'description': 'Mục đích: Chất làm dịu da, Chống viêm, Chống oxy hóa',
      'tag': 'Làm dịu da, Phục hồi da',
    },
    {
      'name': 'Niacinamide',
      'risk': '1-2',
      'description': 'Mục đích: Vitamin B3, Làm sáng da, Kiểm soát nhờn, Giảm mụn',
      'tag': 'Làm sáng da, Kiểm soát dầu',
    },
    {
      'name': 'Hyaluronic Acid',
      'risk': '1',
      'description': 'Mục đích: Chất dưỡng ẩm sâu, Giữ nước, Làm mềm da',
      'tag': 'Dưỡng ẩm sâu, Chống lão hóa',
    },
    {
      'name': 'Propanediol',
      'risk': '1-2',
      'description': 'Mục đích: Dung môi, Chất dưỡng ẩm, Cải thiện kết cấu',
      'tag': 'Dưỡng ẩm da, Cải thiện kết cấu',
    },
    {
      'name': 'Panthenol',
      'risk': '1',
      'description': 'Mục đích: Vitamin B5, Làm dịu da, Giữ ẩm, Phục hồi da',
      'tag': 'Dưỡng ẩm da, Phục hồi da',
    },
    {
      'name': 'Sodium Hyaluronate',
      'risk': '1',
      'description': 'Mục đích: Chất dưỡng ẩm cao phân tử, Cải thiện nếp nhăn',
      'tag': 'Dưỡng ẩm sâu, Chống lão hóa',
    },
    {
      'name': 'Adenosine',
      'risk': '1',
      'description': 'Mục đích: Chất chống lão hóa, Làm mờ nếp nhăn',
      'tag': 'Chống lão hóa, Làm mờ nếp nhăn',
    },
    {
      'name': 'Allantoin',
      'risk': '1',
      'description': 'Mục đích: Làm dịu da, Chống kích ứng, Kích thích tái tạo da',
      'tag': 'Làm dịu da, Phục hồi da',
    },
    {
      'name': 'Ethylhexylglycerin',
      'risk': '2',
      'description': 'Mục đích: Chất bảo quản, Chất dưỡng ẩm nhẹ',
      'tag': 'Bảo quản, Dưỡng ẩm nhẹ',
    },
    {
      'name': 'Carbomer',
      'risk': '1-2',
      'description': 'Mục đích: Chất làm đặc, Ổn định công thức',
      'tag': 'Điều chỉnh kết cấu',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Phân tích thành phần',
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '성분 구성',
                    style: GoogleFonts.notoSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '제품의 안전성과 효과를 평가하는 성분 분석입니다',
                    style: GoogleFonts.notoSans(
                      color: Colors.grey[600],
                      fontSize: 14,
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildRiskIndicator('1-2', '낮은 위험', Colors.green),
                        _buildRiskIndicator('3-6', '중간 위험', Colors.orange),
                        _buildRiskIndicator('7-10', '높은 위험', Colors.red[400]!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final ingredient = ingredients[index];
                  return _buildIngredientItem(
                    name: ingredient['name']!,
                    risk: ingredient['risk']!,
                    description: ingredient['description']!,
                    tag: ingredient['tag']!,
                  );
                },
                childCount: ingredients.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(String risk, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                risk,
                style: GoogleFonts.notoSans(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientItem({
    required String name,
    required String risk,
    required String description,
    required String tag,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {}, // 터치 효과를 위한 빈 콜백
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildRiskBadge(risk),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: tag.split(', ').map((t) => _buildTag(t)).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    final color = _getRiskColor(risk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '위험도 $risk',
        style: GoogleFonts.notoSans(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getRiskColor(String risk) {
    final riskValue = int.tryParse(risk.split('-').first) ?? 1;
    if (riskValue >= 7) {
      return Colors.red[400]!;
    } else if (riskValue >= 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}