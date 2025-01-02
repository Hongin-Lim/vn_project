import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

/// Facebook 로그인 결과를 담는 클래스
/// [userCredential]: Firebase 인증 정보
/// [userData]: Facebook에서 제공하는 사용자 데이터
class FacebookSignInResult {
  final UserCredential userCredential;
  final Map<String, dynamic> userData;

  FacebookSignInResult({
    required this.userCredential,
    required this.userData,
  });
}

/// Facebook 로그인 관련 기능을 처리하는 서비스 클래스
class FacebookAuthService {
  // Facebook 인증 인스턴스
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  // Firebase 인증 인스턴스
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Facebook 로그인 수행
  /// 로그인 성공 시 [FacebookSignInResult] 반환
  /// 실패 시 null 반환
  Future<FacebookSignInResult?> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
        loginBehavior: LoginBehavior.dialogOnly,
      );

      if (loginResult.status == LoginStatus.success) {
        final AccessToken accessToken = loginResult.accessToken!;
        final userData = await _facebookAuth.getUserData(
          fields: "id,name,email,picture.width(400).height(400)",
        );

        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);

        try {
          UserCredential? userCredential;

          if (_firebaseAuth.currentUser != null) {
            // 기존 유저 문서 가져오기
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(_firebaseAuth.currentUser!.uid)
                .get();

            if (userDoc.exists) {
              final existingUser = UserModel.fromFirestore(userDoc);

              // 이미 Facebook 계정이 연결되어 있는지 확인
              if (existingUser.hasLinkedProvider('facebook')) {
                print('이미 연결된 Facebook 계정입니다.');
                return null;
              }

              try {
                userCredential = await _firebaseAuth.currentUser?.linkWithCredential(credential);
                if (userCredential != null) {
                  // UserModel의 withLinkedProvider를 사용하여 Facebook provider 추가
                  final updatedUser = existingUser.withLinkedProvider('facebook');
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_firebaseAuth.currentUser!.uid)
                      .set(updatedUser.toFirestore(), SetOptions(merge: true));

                  print('Facebook 계정이 성공적으로 연결되었습니다.');
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

          if (userCredential != null) {
            await _updateUserInFirestore(userCredential, userData);
            return FacebookSignInResult(
              userCredential: userCredential,
              userData: userData,
            );
          }
        } on FirebaseAuthException catch (e) {
          String errorMessage = '';
          switch (e.code) {
            case 'account-exists-with-different-credential':
              errorMessage = '이미 다른 방법으로 가입된 계정입니다.';
              break;
            case 'invalid-credential':
              errorMessage = '인증 정보가 유효하지 않습니다.';
              break;
            default:
              errorMessage = '로그인 중 오류가 발생했습니다: ${e.message}';
          }
          print(errorMessage);
          return null;
        }
      }
      return null;
    } catch (e) {
      print('Facebook 로그인 중 예상치 못한 에러 발생: $e');
      return null;
    }
  }

// Firestore 업데이트를 위한 보조 메서드
  Future<void> _updateUserInFirestore(UserCredential userCredential, Map<String, dynamic> userData) async {
    try {
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
        // 새 사용자의 경우 UserModel의 fromFacebookAuth 사용
        final newUser = UserModel.fromFacebookAuth(userCredential, userData);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(newUser.toFirestore());
      }
    } catch (e) {
      print("Firestore 업데이트 중 오류 발생: $e");
    }
  }
  /// Facebook과 Firebase에서 로그아웃
  Future<void> signOut() async {
    try {
      await _facebookAuth.logOut();  // Facebook 로그아웃
      await _firebaseAuth.signOut(); // Firebase 로그아웃
      print('로그아웃 성공');
    } catch (e) {
      print('로그아웃 중 에러 발생: $e');
      throw e; // UI에서 처리할 수 있도록 에러 전파
    }
  }

  /// 현재 Facebook 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _facebookAuth.accessToken;
      return accessToken != null;
    } catch (e) {
      print('로그인 상태 확인 중 에러 발생: $e');
      return false;
    }
  }

  /// 사용자의 추가 정보 입력 필요 여부 확인
  /// 필수 정보가 하나라도 비어있으면 true 반환
  Future<bool> needsAdditionalInfo(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return true;

      final userData = userDoc.data()!;

      // 필수 정보 존재 여부 확인
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