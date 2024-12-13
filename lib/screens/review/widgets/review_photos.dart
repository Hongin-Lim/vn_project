// lib/screens/review/widgets/review_photos.dart

import 'package:flutter/material.dart';

class ReviewPhotos extends StatelessWidget {
  final List<String> photoUrls;

  const ReviewPhotos({
    required this.photoUrls,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 400,
          width: double.infinity,
          child: PageView.builder(
            itemCount: photoUrls.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Image.network(
                  photoUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}