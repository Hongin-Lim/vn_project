import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 회원가입
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email này đã được sử dụng';
          break;
        case 'weak-password':
          errorMessage = 'Mật khẩu quá yếu';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ';
          break;
        default:
          errorMessage = 'Đã xảy ra lỗi: ${e.message}';
      }
      throw Exception(errorMessage);
    }
  }

  // 로그인
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Không tìm thấy người dùng với email này';
          break;
        case 'wrong-password':
          errorMessage = 'Sai mật khẩu';
          break;
        case 'invalid-email':
          errorMessage = 'Email không hợp lệ';
          break;
        default:
          errorMessage = 'Đã xảy ra lỗi: ${e.message}';
      }
      throw Exception(errorMessage);
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 비밀번호 재설정
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Không thể gửi email đặt lại mật khẩu: ${e.message}');
    }
  }

  // 계정 삭제
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Không thể xóa tài khoản: ${e.message}');
    }
  }

  // 현재 사용자 가져오기
  User? get currentUser => _auth.currentUser;
}

  // /// 비밀번호 재설정 이메일 보내기
  // Future<void> sendPasswordResetEmail(String email) async {
  //   try {
  //     await _auth.sendPasswordResetEmail(email: email);
  //     print("Password reset email sent to $email");
  //   } catch (e) {
  //     print("Error sending password reset email: $e");
  //   }
  // }
  //
  // /// 이메일 인증
  // Future<void> sendEmailVerification() async {
  //   try {
  //     User? user = _auth.currentUser;
  //     if (user != null && !user.emailVerified) {
  //       await user.sendEmailVerification();
  //       print("Verification email sent to ${user.email}");
  //     }
  //   } catch (e) {
  //     print("Error sending verification email: $e");
  //   }
  // }
  //
  // /// 인증 상태 변경 리스너
  // void authStateChanges(Function(User?) onUserChanged) {
  //   _auth.authStateChanges().listen((User? user) {
  //     onUserChanged(user);
  //   });
  // }
// }
