import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 현재 로그인된 사용자가 있는지 확인
        if (_firebaseAuth.currentUser != null) {
          // 기존 유저 문서 가져오기
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(_firebaseAuth.currentUser!.uid)
              .get();

          if (userDoc.exists) {
            final existingUser = UserModel.fromFirestore(userDoc);

            // 이미 Google 계정이 연결되어 있는지 확인
            if (existingUser.hasLinkedProvider('google')) {
              print('이미 연결된 Google 계정입니다.');
              return null;
            }

            try {
              // 기존 계정에 Google 계정 연결
              userCredential = await _firebaseAuth.currentUser?.linkWithCredential(credential);
              if (userCredential != null) {
                // UserModel의 withLinkedProvider를 사용하여 Google provider 추가
                final updatedUser = existingUser.withLinkedProvider('google');
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_firebaseAuth.currentUser!.uid)
                    .set(updatedUser.toFirestore(), SetOptions(merge: true));

                print('Google 계정이 성공적으로 연결되었습니다.');
              }
            } catch (e) {
              print('계정 연결 중 오류 발생: $e');
              return null;
            }
          }
        } else {
          // 새로운 로그인 시도
          userCredential = await _firebaseAuth.signInWithCredential(credential);
        }
      }

      if (userCredential?.user != null) {
        await _updateUserInFirestore(userCredential!);
      }

      return userCredential;
    } catch (e) {
      print('Google 로그인 중 예상치 못한 에러 발생: $e');
      return null;
    }
  }

// Firestore 업데이트를 위한 보조 메서드
  Future<void> _updateUserInFirestore(UserCredential userCredential) async {
    final user = userCredential.user;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      // UserModel을 사용하여 기존 데이터 로드
      final existingUser = UserModel.fromFirestore(userDoc);
      // lastLoginAt만 업데이트
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'lastLoginAt': DateTime.now()});
    } else {
      // 새 사용자의 경우 UserModel의 fromGoogleAuth 사용
      final newUser = UserModel.fromGoogleAuth(userCredential);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(newUser.toFirestore());
    }
  }
  /// Google과 Firebase에서 로그아웃
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        // 모바일 앱에서만 Google Sign-In 로그아웃 필요
        await _googleSignIn.signOut();
      }
      // 모든 플랫폼에서 Firebase 로그아웃
      await _firebaseAuth.signOut();
      print('로그아웃 성공');
    } catch (e) {
      print('로그아웃 중 에러 발생: $e');
      throw e;
    }
  }

  /// 현재 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    try {
      final user = _firebaseAuth.currentUser;
      return user != null;
    } catch (e) {
      print('로그인 상태 확인 중 에러 발생: $e');
      return false;
    }
  }

  /// 사용자의 추가 정보 입력 필요 여부 확인
  Future<bool> needsAdditionalInfo(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return true;

      final userData = userDoc.data()!;

      return userData['gender']?.isEmpty ?? true ||
          userData['birthDate'] == null ||
          userData['region']?.isEmpty ?? true ||
          userData['skinType']?.isEmpty ?? true;
    } catch (e) {
      print('추가 정보 확인 중 에러 발생: $e');
      return true;
    }
  }
}