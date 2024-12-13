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
  // Future<Map<String, dynamic>?> getUserData(String userId)  // Raw 데이터 반환
  Future<UserModel?> loadUserData(String userId) async { // UserModel 객체 반환
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

  /// 리뷰 추가
  Future<void> addReview(String productId, Review review, List<String> photoPaths) async {
    try {
      // 1. 사진 업로드
      final photoUrls = await Future.wait(
        photoPaths.map((path) => uploadPhoto(review.userId, path)),
      );

      // 2. 리뷰 저장 및 제품 통계 업데이트를 트랜잭션으로 처리
      await _firestore.runTransaction((transaction) async {
        // 리뷰 추가
        final reviewRef = _firestore.collection('reviews').doc();
        transaction.set(reviewRef, {
          'productId': productId,
          'userId': review.userId,
          'content': review.content,
          'rating': review.rating,
          'photoUrls': photoUrls,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 제품 통계 업데이트
        final productRef = _firestore.collection('products').doc(productId);
        final productDoc = await transaction.get(productRef);

        if (productDoc.exists) {
          final currentCount = productDoc.data()?['reviewCount'] ?? 0;
          final currentAverage = productDoc.data()?['averageRating'] ?? 0.0;

          final newCount = currentCount + 1;
          final newAverage = ((currentAverage * currentCount) + review.rating) / newCount;

          transaction.update(productRef, {
            'reviewCount': newCount,
            'averageRating': newAverage,
          });
        }
      });
    } catch (e) {
      throw Exception('리뷰 추가 실패: $e');
    }
  }

  /// 특정 리뷰 조회
  Future<Review?> getReview(String reviewId) async {
    try {
      final doc = await _firestore.collection('reviews').doc(reviewId).get();
      if (doc.exists) {
        return Review.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('리뷰 조회 실패: $e');
    }
  }

  /// 리뷰 수정 권한 확인
  Future<bool> canModifyReview(String userId, String reviewId) async {
    try {
      final review = await getReview(reviewId);
      if (review == null) return false;

      // 작성자이거나 관리자인 경우 수정 가능
      final hasAdminRole = await isAdmin(userId);
      return review.userId == userId || hasAdminRole;
    } catch (e) {
      return false;
    }
  }

  /// 리뷰 수정
  Future<void> updateReview(String reviewId, Review updatedReview, List<String> newPhotoPaths) async {
    try {
      // 기존 리뷰 데이터 가져오기
      final oldReview = await getReview(reviewId);
      if (oldReview == null) {
        throw Exception('리뷰를 찾을 수 없습니다');
      }

      // 새로운 사진 업로드
      final photoUrls = await Future.wait(
          newPhotoPaths.map((path) => uploadPhoto(updatedReview.userId, path))
      );

      // 리뷰 데이터 업데이트
      await _firestore.runTransaction((transaction) async {
        final reviewRef = _firestore.collection('reviews').doc(reviewId);
        final productRef = _firestore.collection('products').doc(updatedReview.productId);

        // 제품 통계 업데이트
        final productDoc = await transaction.get(productRef);
        if (productDoc.exists) {
          final currentCount = productDoc.data()?['reviewCount'] ?? 0;
          final currentAverage = productDoc.data()?['averageRating'] ?? 0.0;

          // 이전 평점 제거 후 새 평점 추가
          final newAverage = ((currentAverage * currentCount) - oldReview.rating + updatedReview.rating) / currentCount;

          transaction.update(productRef, {
            'averageRating': newAverage,
          });
        }

        // 리뷰 업데이트
        transaction.update(reviewRef, {
          ...updatedReview.toFirestore(),
          'photoUrls': photoUrls,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('리뷰 수정 실패: $e');
    }
  }

  /// 리뷰 삭제
  Future<void> deleteReview(String reviewId) async {
    try {
      // 리뷰 데이터 가져오기
      final review = await getReview(reviewId);
      if (review == null) {
        throw Exception('리뷰를 찾을 수 없습니다');
      }

      await _firestore.runTransaction((transaction) async {
        final reviewRef = _firestore.collection('reviews').doc(reviewId);
        final productRef = _firestore.collection('products').doc(review.productId);

        // 제품 통계 업데이트
        final productDoc = await transaction.get(productRef);
        if (productDoc.exists) {
          final currentCount = productDoc.data()?['reviewCount'] ?? 0;
          final currentAverage = productDoc.data()?['averageRating'] ?? 0.0;

          if (currentCount > 1) {
            final newCount = currentCount - 1;
            final newAverage = ((currentAverage * currentCount) - review.rating) / newCount;

            transaction.update(productRef, {
              'reviewCount': newCount,
              'averageRating': newAverage,
            });
          } else {
            // 마지막 리뷰인 경우
            transaction.update(productRef, {
              'reviewCount': 0,
              'averageRating': 0,
            });
          }
        }

        // 리뷰 삭제
        transaction.delete(reviewRef);
      });

      // 리뷰 사진 삭제 (옵션)
      for (String photoUrl in review.photoUrls) {
        try {
          await _storage.refFromURL(photoUrl).delete();
        } catch (e) {
          print('사진 삭제 실패: $e');
        }
      }
    } catch (e) {
      throw Exception('리뷰 삭제 실패: $e');
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
  // updateProduct 방식 - 위험!
  // await _firestoreService.updateProduct(productId, {
  //   'nmae': '새이름',  // 오타 있어도 컴파일러가 못 잡음
  //   'desc': '새설명'   // 잘못된 필드명이어도 못 잡음
  // });
  //
  // // copyWith 방식 - 안전!
  // final updatedProduct = oldProduct.copyWith(
  //   nmae: '새이름',    // 컴파일 에러! (오타 감지)
  //   desc: '새설명'     // 컴파일 에러! (잘못된 필드명 감지)
  // );
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

}

