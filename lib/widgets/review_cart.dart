import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String content;
  final int rating;

  const ReviewCard({required this.content, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Rating: $rating/5',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
