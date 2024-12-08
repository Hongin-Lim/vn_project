import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/product_model.dart';
import '../models/review.model.dart';

/// Firestore와 Firebase Storage를 사용한 데이터 관리 서비스
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Firebase Storage에 사진 업로드 후 URL 반환
  Future<String> uploadPhoto(String userId, String filePath) async {
    try {
      final ref = _storage
          .ref()
          .child('reviewPhotos/$userId/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('사진 업로드 중 오류 발생: $e');
    }
  }

  Future<List<Product>> fetchProducts({String? category}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('products');
      if (category != null && category != 'Tất cả') {
        query = query.where('category', isEqualTo: category);
      }
      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return Product.fromFirestore(doc);
      }).toList();
    } catch (e) {
      throw Exception('제품 목록 가져오기 실패: $e');
    }
  }

  /// 특정 제품 가져오기
  Future<Product?> fetchProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('제품 정보 가져오기 실패: $e');
    }
  }

  /// 리뷰 가져오기 (특정 제품에 대한)
  Future<List<Review>> fetchReviews(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('리뷰 목록 가져오기 실패: $e');
    }
  }

  /// 리뷰 추가
  Future<void> addReview(String productId, Review review, List<String> photoPaths) async {
    try {
      final photoUrls = await Future.wait(
        photoPaths.map((path) => uploadPhoto(review.userId, path)),
      );

      await _firestore.collection('reviews').add({
        'productId': productId,
        'userId': review.userId,
        'content': review.content,
        'rating': review.rating,
        'photoUrls': photoUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final productRef = _firestore.collection('products').doc(productId);
      final productSnapshot = await productRef.get();

      if (productSnapshot.exists) {
        final productData = productSnapshot.data()!;
        final currentReviewCount = productData['reviewCount'] ?? 0;
        final currentAverageRating = productData['averageRating'] ?? 0.0;

        final newReviewCount = currentReviewCount + 1;
        final newAverageRating = ((currentAverageRating * currentReviewCount) + review.rating) / newReviewCount;

        await productRef.update({
          'reviewCount': newReviewCount,
          'averageRating': newAverageRating,
        });
      }
    } catch (e) {
      throw Exception('리뷰 추가 실패: $e');
    }
  }

  /// 리뷰 수정
  Future<void> updateReview(String reviewId, String productId, Review updatedReview, List<String> newPhotoPaths) async {
    try {
      final photoUrls = await Future.wait(
        newPhotoPaths.map((path) => uploadPhoto(updatedReview.userId, path)),
      );

      final reviewRef = _firestore.collection('reviews').doc(reviewId);
      await reviewRef.update({
        'content': updatedReview.content,
        'rating': updatedReview.rating,
        'photoUrls': photoUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final productRef = _firestore.collection('products').doc(productId);
      final productSnapshot = await productRef.get();

      if (productSnapshot.exists) {
        final productData = productSnapshot.data()!;
        final currentReviewCount = productData['reviewCount'] ?? 0;
        final currentAverageRating = productData['averageRating'] ?? 0.0;

        final newAverageRating = ((currentAverageRating * currentReviewCount) + updatedReview.rating) / currentReviewCount;

        await productRef.update({'averageRating': newAverageRating});
      }
    } catch (e) {
      throw Exception('리뷰 수정 실패: $e');
    }
  }

  /// 제품 수정
  Future<void> updateProduct(String productId, Product updatedProduct) async {
    try {
      await _firestore.collection('products').doc(productId).update(updatedProduct.toFirestore());
    } catch (e) {
      throw Exception('제품 수정 실패: $e');
    }
  }

  /// 제품 추가
  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').add(product.toFirestore());
    } catch (e) {
      throw Exception('제품 추가 실패: $e');
    }
  }

  /// 제품 삭제
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('제품 삭제 실패: $e');
    }
  }

  /// 리뷰 삭제
  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw Exception('리뷰 삭제 실패: $e');
    }
  }
}
