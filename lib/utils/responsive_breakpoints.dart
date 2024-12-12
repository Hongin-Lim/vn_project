// lib/utils/responsive_breakpoints.dart

import 'package:flutter/material.dart';

/// 반응형 레이아웃을 위한 유틸리티 클래스
class ResponsiveBreakpoints {
  /// 데스크톱 화면 여부 확인
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 1200;

  /// 태블릿 화면 여부 확인
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
          MediaQuery.of(context).size.width <= 1200;

  /// 모바일 화면 여부 확인
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  /// 화면 크기에 따른 수평 패딩 값 반환
  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return MediaQuery.of(context).size.width * 0.1;
    if (isTablet(context)) return 32.0;
    return 16.0;
  }
}