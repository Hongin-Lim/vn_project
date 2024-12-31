import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/facebook_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final FacebookAuthService _facebookAuthService = FacebookAuthService();
  User? _user;

  User? get user => _user;

  Future<bool> signInWithFacebook() async {
    try {
      final userCredential = await _facebookAuthService.signInWithFacebook();
      if (userCredential != null) {
        _user = userCredential.user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('로그인 에러: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _facebookAuthService.signOut();
    _user = null;
    notifyListeners();
  }
}