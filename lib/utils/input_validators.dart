
import 'package:flutter/cupertino.dart';

/// 입력값 검증을 위한 유틸리티 클래스
class InputValidators {
  /// 필수 입력 검증
  static FormFieldValidator<String> required(String message) {
    return (value) {
      if (value == null || value.isEmpty) {
        return message;
      }
      return null;
    };
  }

  /// URL 형식 검증
  static FormFieldValidator<String> url(String message) {
    return (value) {
      if (value == null || value.isEmpty) {
        return message;
      }

      final urlPattern = RegExp(
        r'^(http|https)://[^\s/$.?#].[^\s]*$',
        caseSensitive: false,
      );

      if (!urlPattern.hasMatch(value)) {
        return '올바른 URL 형식이 아닙니다';
      }

      return null;
    };
  }
}