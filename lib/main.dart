import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 플랫폼 감지를 위한 kIsWeb 임포트
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:vn_project/screens/auth/email_login_screen.dart' as email;
import 'package:vn_project/screens/auth/login_screen.dart' as login;
import 'package:vn_project/screens/auth/signup_screen.dart';
import 'package:vn_project/screens/product/product_detail_screen.dart';

import 'firebase_options.dart'; // Firebase CLI로 생성된 플랫폼별 설정 파일
import 'screens/home/home_screen.dart';
/// 앱의 진입점
void main() async {
  // Flutter 엔진과 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    FacebookAuth.i.webAndDesktopInitialize(
        appId: "437874102595744",
        cookie: true,
        xfbml: true,
        version: "v18.0"
    );

    // 웹 플랫폼 감지 시 웹용 Firebase 초기화
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyACa_AQoox_tUS8MXfaHFIBk4ukgNF2zoQ", // 웹 API 키
        authDomain: "benepick-7d89f.firebaseapp.com", // Firebase 인증 도메인
        projectId: "benepick-7d89f", // Firebase 프로젝트 ID
        storageBucket: "benepick-7d89f.firebasestorage.app", // Firebase Storage 버킷 주소
        messagingSenderId: "165719448160", // Firebase Cloud Messaging sender ID
        appId: "1:165719448160:web:cc3ea908b2bfbd135cc105", // Firebase 앱 ID
      ),
    );
  } else {
    // 모바일 플랫폼일 경우 기본 Firebase 설정으로 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // firebase_options.dart에서 가져옴
    );
  }

  // 앱 실행
  runApp(MyApp());
}

/// 앱의 루트 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 숨기기
      title: 'BenePick', // 앱 타이틀
      theme: ThemeData(
        primarySwatch: Colors.blue, // 앱의 기본 색상 테마
        visualDensity: VisualDensity.adaptivePlatformDensity, // 플랫폼에 맞는 시각적 밀도 설정
      ),
      initialRoute: '/home', // 초기 라우트 설정
      // 정적 라우트 정의
      routes: {
        '/signup': (context) => SignupScreen(), // 회원가입 화면
        '/login': (context) => login.LoginScreen(), // 일반 로그인 화면
        '/home': (context) => HomeScreen(), // 홈 화면
        '/email-login': (context) => email.EmailLoginScreen(), // 이메일 로그인 화면
      },
      // 동적 라우트 처리
      onGenerateRoute: (settings) {
        // 제품 상세 페이지 라우트 처리
        if (settings.name == '/product/detail') {
          final productId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: productId),
          );
        }
        return null; // 정의되지 않은 라우트는 null 반환
      },
    );
  }
}

/// Firebase Authentication 상태에 따라 적절한 화면으로 리다이렉트하는 위젯
class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 현재 로그인된 사용자 정보 가져오기
    final user = FirebaseAuth.instance.currentUser;

    // 사용자 로그인 상태에 따른 화면 분기 처리
    if (user != null) {
      // 로그인된 상태 -> 홈 화면으로 이동
      return HomeScreen();
    } else {
      // 로그인되지 않은 상태 -> 홈 화면으로 이동 (임시, 원래는 로그인 화면)
      // return LoginScreen();
      return HomeScreen();
    }
  }
}