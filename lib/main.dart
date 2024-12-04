import 'package:firebase_core/firebase_core.dart'; // Firebase 초기화 패키지
import 'package:flutter/material.dart';

import 'firebase_options.dart'; // Firebase 설정 파일 (CLI로 생성)
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 작업 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 플랫폼별 Firebase 설정
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}
