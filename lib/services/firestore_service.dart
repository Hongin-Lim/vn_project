import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/product_model.dart';
import '../models/review.model.dart';
import '../models/user_model.dart';

/// Firestore와 Firebase Storage를 사용한 데이터 관리 서비스
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 사용자 생성
  Future<void> createUser(String userId, UserModel user) async {
    try {
      await _firestore.collection('users').doc(userId).set(user.toFirestore());
    } catch (e) {
      throw Exception('Không thể tạo người dùng: $e');
    }
  }

  // 사용자 정보 업데이트
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Không thể cập nhật thông tin người dùng: $e');
    }
  }

  // 사용자 데이터 로드
  Future<UserModel?> loadUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể tải thông tin người dùng: $e');
    }
  }

  // 마지막 로그인 시간 업데이트
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Không thể cập nhật thời gian đăng nhập cuối cùng: $e');
    }
  }

  // 사용자 데이터 삭제
  Future<void> deleteUserData(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Không thể xóa dữ liệu người dùng: $e');
    }
  }

  /// 사용자의 권한(role) 조회
  Future<String> getUserRole(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data()!.containsKey('role')) {
        return docSnapshot.data()!['role'] as String;
      }
      return ''; // 기본값 반환
    } catch (e) {
      print('Error getting user role: $e');
      return ''; // 에러 발생시 빈 문자열 반환
    }
  }


  /// Firebase Storage에 사진 업로드 후 URL 반환
  Future<String> uploadPhoto(String userId, String filePath) async {
    try {
      final ref = _storage
          .ref()
          .child('reviewPhotos/$userId/${DateTime
          .now()
          .millisecondsSinceEpoch}');
      final uploadTask = ref.putFile(File(filePath));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('사진 업로드 중 오류 발생: $e');
    }
  }

  // Future<List<Product>> fetchProducts({String? category}) async {
  //   try {
  //     Query<Map<String, dynamic>> query = _firestore.collection('products');
  //     if (category != null && category != 'Tất cả') {
  //       query = query.where('category', isEqualTo: category);
  //     }
  //     final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
  //
  //     return snapshot.docs.map((
  //         QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  //       return Product.fromFirestore(doc);
  //     }).toList();
  //   } catch (e) {
  //     throw Exception('제품 목록 가져오기 실패: $e');
  //   }
  // }

  // /// 특정 제품 가져오기
  // Future<Product?> fetchProductById(String productId) async {
  //   try {
  //     final doc = await _firestore.collection('products').doc(productId).get();
  //     if (doc.exists) {
  //       return Product.fromFirestore(doc);
  //     }
  //     return null;
  //   } catch (e) {
  //     throw Exception('제품 정보 가져오기 실패: $e');
  //   }
  // }

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
  Future<void> addReview(String productId, Review review,
      List<String> photoPaths) async {
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
        final newAverageRating = ((currentAverageRating * currentReviewCount) +
            review.rating) / newReviewCount;

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
  Future<void> updateReview(String reviewId, String productId,
      Review updatedReview, List<String> newPhotoPaths) async {
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

        final newAverageRating = ((currentAverageRating * currentReviewCount) +
            updatedReview.rating) / currentReviewCount;

        await productRef.update({'averageRating': newAverageRating});
      }
    } catch (e) {
      throw Exception('리뷰 수정 실패: $e');
    }
  }



  /// [product]: 추가할 상품 정보
  /// throws Exception: Firestore 작업 실패 시
  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').add({
        'name': product.name,
        'description': product.description,
        'category': product.category,
        'imageUrl': product.imageUrl,
        'reviewCount': product.reviewCount,     // 초기값 0
        'averageRating': product.averageRating, // 초기값 0.0
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('상품 추가 실패: $e');
    }
  }

  /// 카테고리별 상품 목록 조회
  /// 페이징 처리된 상품 목록 조회: product_list_screen.dart에서 사용
  Future<List<Product>> getProducts({
    String? category,
    Product? lastProduct,
    int limit = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('products')
          .limit(limit);

      if (category != null && category != 'Tất cả') {
        query = query.where('category', isEqualTo: category);
      }

      if (lastProduct != null) {
        query = query.startAfterDocument(
            await _firestore.collection('products').doc(lastProduct.id).get()
        );
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('상품 목록 조회 실패: $e');
    }
  }

  /// 특정 상품의 상세 정보 조회: product_detail_screen.dart에서 사용
  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('상품 정보 조회 실패: $e');
    }
  }

  /// 특정 상품의 리뷰 목록 스트림 조회: product_detail_screen.dart에서 사용
  Stream<QuerySnapshot> getProductReviews(String productId) {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// 사용자 권한 확인: product_detail_screen.dart에서 사용
  Future<bool> isAdmin(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists && doc.data()?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// 상품 정보 수정: product_detail_screen.dart에서 사용
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('products').doc(productId).update(data);
    } catch (e) {
      throw Exception('상품 정보 수정 실패: $e');
    }
  }

  /// 상품 삭제: product_detail_screen.dart에서 사용
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('상품 삭제 실패: $e');
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

