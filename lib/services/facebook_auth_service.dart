import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Facebook 로그인 결과를 담는 클래스
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
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Facebook 로그인 수행
  Future<FacebookSignInResult?> signInWithFacebook() async {
    try {
      // Facebook 로그인 시도
      final LoginResult loginResult = await _facebookAuth.login(
        permissions: [
          'email',
          'public_profile',
          // 'user_gender',  // 성별 정보가 필요한 경우
          // 'user_birthday',// 생년월일 정보가 필요한 경우
        ],
        loginBehavior: LoginBehavior.dialogOnly,
      );

      // 로그인 상태 확인
      switch (loginResult.status) {
        case LoginStatus.success:
        // Facebook 액세스 토큰 획득
          final AccessToken accessToken = loginResult.accessToken!;

          // Facebook 사용자 데이터 획득 (고화질 프로필 사진 포함)
          final userData = await _facebookAuth.getUserData(
            fields: "name,email,picture.width(400).height(400)", // 고화질 이미지 요청
          );

          print("Facebook 사용자 데이터: $userData");

          // 프로필 이미지 URL 추출
          final profileImageUrl = userData['picture']?['data']?['url'];
          print("프로필 이미지 URL: $profileImageUrl");

          // Firebase 인증 정보 생성
          final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.token);

          try {
            // Firebase 로그인 수행
            final userCredential =
            await _firebaseAuth.signInWithCredential(credential);

            print('Firebase 로그인 성공');
            print('사용자 이메일: ${userCredential.user?.email}');
            print('사용자 이름: ${userCredential.user?.displayName}');
            print('프로필 URL: ${userCredential.user?.photoURL}');

            // FacebookSignInResult 객체로 반환
            return FacebookSignInResult(
              userCredential: userCredential,
              userData: userData,
            );
          } on FirebaseAuthException catch (e) {
            // Firebase 인증 관련 에러 처리
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

        case LoginStatus.cancelled:
          print('Facebook 로그인이 사용자에 의해 취소되었습니다.');
          return null;

        case LoginStatus.failed:
          print('Facebook 로그인 실패: ${loginResult.message}');
          return null;

        default:
          print('처리되지 않은 상태: ${loginResult.status}');
          return null;
      }
    } catch (e) {
      print('Facebook 로그인 중 예상치 못한 에러 발생: $e');
      return null;
    }
  }

  /// Facebook 로그아웃
  Future<void> signOut() async {
    try {
      await _facebookAuth.logOut();
      await _firebaseAuth.signOut();
      print('로그아웃 성공');
    } catch (e) {
      print('로그아웃 중 에러 발생: $e');
      throw e; // 에러를 상위로 전파하여 UI에서 처리할 수 있도록 함
    }
  }

  /// 현재 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await _facebookAuth.accessToken;
      return accessToken != null;
    } catch (e) {
      print('로그인 상태 확인 중 에러 발생: $e');
      return false;
    }
  }
}