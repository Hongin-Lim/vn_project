import 'package:flutter/material.dart';

class IngredientAnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ingredients = [
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

    // final ingredients = [
    //   {
    //     'name': '정제수, 증류수, 물',
    //     'risk': '1',
    //     'description': '배합목적: 용제, 피부컨디셔닝제',
    //     'tag': '피부 보습',
    //   },
    //   {
    //     'name': '글리세린',
    //     'risk': '1-2',
    //     'description':
    //     '배합목적: 헤어컨디셔닝제, 보습제, 착향제, 변성제, 점도조정제, 피부보호제',
    //     'tag': '피부 보습, 피부 보호',
    //   },
    //   {
    //     'name': '소듐코코일글라이시네이트, 소듐코코일글리시네이트(구명칭)',
    //     'risk': '1',
    //     'description': '배합목적: 계면활성제(세정제), 헤어컨디셔닝제, 피부컨디셔닝제',
    //     'tag': '피부 보습',
    //   },
    //   {
    //     'name': '소듐라우로일글루타메이트',
    //     'risk': '1',
    //     'description': '배합목적: 헤어컨디셔닝제',
    //     'tag': '피부 보습',
    //   },
    // ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Phân tích thành phần'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 설명 및 범례
            Text(
              '성분 구성',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRiskIndicator('1-2', '낮은 위험', Colors.blue),
                _buildRiskIndicator('3-6', '중간 위험', Colors.orange),
                _buildRiskIndicator('7-10', '높은 위험', Colors.red),
              ],
            ),
            SizedBox(height: 20),
            // 성분 리스트
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  return _buildIngredientItem(
                    ingredient['name']!,
                    ingredient['risk']!,
                    ingredient['description']!,
                    ingredient['tag']!,
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
        SizedBox(width: 8),
        Text(
          '$risk $label',
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(
      String name, String risk, String description, String tag) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue,
                child: Text(
                  risk,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 4),
                Text(
                  tag,
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
