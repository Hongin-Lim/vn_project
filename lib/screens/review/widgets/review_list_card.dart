// 일단 안씀
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/review.model.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({
    required this.review,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildContent(),
            if (review.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPhotoGrid(),
            ],
            const SizedBox(height: 12),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            review.title,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildRatingStars(),
      ],
    );
  }

  Widget _buildRatingStars() {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < review.rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildContent() {
    return Text(
      review.content,
      style: GoogleFonts.notoSans(
        fontSize: 14,
        height: 1.5,
        color: Colors.black87,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPhotoGrid() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: review.photoUrls.length,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(review.photoUrls[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      review.createdAt.toString().split(' ')[0],
      style: GoogleFonts.notoSans(
        fontSize: 12,
        color: Colors.grey[500],
      ),
    );
  }
}