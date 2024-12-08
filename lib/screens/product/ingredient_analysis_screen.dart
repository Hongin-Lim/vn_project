import 'package:flutter/material.dart';

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
      'description':
      'Mục đích: Chất dưỡng tóc, Chất dưỡng ẩm, Hương liệu, Chất biến tính, Chất điều chỉnh độ nhớt, Chất bảo vệ da',
      'tag': 'Dưỡng ẩm da, Bảo vệ da',
    },
    {
      'name': 'Sodium Cocoyl Glycinate, Sodium Cocoyl Glycinate (Tên cũ)',
      'risk': '1',
      'description': 'Mục đích: Chất hoạt động bề mặt (Chất tẩy rửa), Chất dưỡng tóc, Chất dưỡng da',
      'tag': 'Dưỡng ẩm da',
    },
    {
      'name': 'Sodium Lauroyl Glutamate',
      'risk': '1',
      'description': 'Mục đích: Chất dưỡng tóc',
      'tag': 'Dưỡng ẩm da',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích thành phần'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 설명 및 범례
            const Text(
              '성분 구성',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRiskIndicator('1-2', '낮은 위험', Colors.blue),
                _buildRiskIndicator('3-6', '중간 위험', Colors.orange),
                _buildRiskIndicator('7-10', '높은 위험', Colors.red),
              ],
            ),
            const SizedBox(height: 20),

            // 성분 리스트
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  return _buildIngredientItem(
                    name: ingredient['name']!,
                    risk: ingredient['risk']!,
                    description: ingredient['description']!,
                    tag: ingredient['tag']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskIndicator(String risk, String label, Color color) {
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: color,
        ),
        const SizedBox(width: 8),
        Text(
          '$risk $label',
          style: const TextStyle(fontSize: 14),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _getRiskColor(risk),
                child: Text(
                  risk,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  tag,
                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Color _getRiskColor(String risk) {
    final riskValue = int.tryParse(risk.split('-').first) ?? 1;
    if (riskValue >= 7) {
      return Colors.red;
    } else if (riskValue >= 3) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }
}
