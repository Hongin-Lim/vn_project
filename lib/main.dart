import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase 초기화 패키지
import 'package:flutter/material.dart';
import 'package:vn_project/screens/auth/login_screen.dart';
import 'package:vn_project/screens/auth/signup_screen.dart';

import 'firebase_options.dart'; // Firebase 설정 파일
import 'screens/home_screen.dart'; // 홈 화면

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 작업 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 플랫폼별 Firebase 설정
  );

  // // Firestore 에뮬레이터 설정
  // FirestoreService().setupFirestoreEmulator(); // 에뮬레이터 설정 호출
  //
  // // Firestore 데이터 초기화
  // await initializeFirestore();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Review App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: HomeScreen(),
      initialRoute: '/home', // 앱 시작 경로 (회원가입 화면)
      routes: {
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

/// 로그인 상태를 확인하여 초기 화면 결정
class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // 로그인 상태 확인 후 적절한 화면으로 리디렉션
    if (user != null) {
      // 이미 로그인된 상태 -> 홈 화면으로 이동
      return HomeScreen();
    } else {
      // 로그인되지 않은 상태 -> 로그인 화면으로 이동
      // return LoginScreen();
      return HomeScreen();
    }
  }
}
