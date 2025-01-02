import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/facebook_auth_service.dart';
import '../../services/google_auth_service.dart';
import 'facebook_additional_info_screen.dart';
import 'google_additional_info_screen.dart'; // 소셜 아이콘용

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FacebookAuthService _facebookAuthService = FacebookAuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFAFAFA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildSocialLogins(),
                  const SizedBox(height: 32),
                  _buildDivider(),
                  const SizedBox(height: 32),
                  _buildEmailLogin(),
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Container(
        //   height: 120,
        //   child: Image.asset('assets/images/logo.png'), // 로고 이미지 추가 필요
        // ),
        // const SizedBox(height: 24),
        Text(
          'BenePick',
          style: GoogleFonts.dancingScript(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFFfa6386),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "당신의 뷰티 여정을 시작하세요",
          style: GoogleFonts.notoSans(
            fontSize: 16,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogins() {
    return Column(
      children: [
        // Google 로그인 버튼
        _buildSocialButton(
          onPressed: () async {
            setState(() => _isLoading = true);
            try {
              final result = await _googleAuthService.signInWithGoogle();
              if (result != null) {
                // 기존 회원인지 확인
                final needsInfo = await _googleAuthService.needsAdditionalInfo(result.user!.uid);

                if (needsInfo) {
                  // 추가 정보가 필요한 경우에만 입력 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GoogleAdditionalInfoScreen(
                        userCredential: result,
                      ),
                    ),
                  );
                } else {
                  // 기존 회원인 경우 메인 화면으로 이동
                  Navigator.pushReplacementNamed(context, '/home');
                }
              }
            } catch (e) {
              print('Google 로그인 중 오류 발생: $e');
              // 에러 처리...
            } finally {
              setState(() => _isLoading = false);
            }
          },
          icon: FontAwesomeIcons.google,
          text: "Google로 계속하기",
          color: Colors.white,
          textColor: Colors.black87,
          borderColor: Colors.grey[300],
        ),
        const SizedBox(height: 16),

        // Facebook 로그인 버튼
        _buildSocialButton(
          onPressed: () async {
            setState(() => _isLoading = true);
            try {
              final result = await _facebookAuthService.signInWithFacebook();
              if (result != null) {
                // 기존 회원인지 확인
                final needsInfo = await _facebookAuthService.needsAdditionalInfo(result.userCredential.user!.uid);

                if (needsInfo) {
                  // 추가 정보가 필요한 경우에만 입력 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FacebookAdditionalInfoScreen(
                        userCredential: result.userCredential,
                        facebookUserData: result.userData,
                      ),
                    ),
                  );
                } else {
                  // 기존 회원인 경우 메인 화면으로 이동
                  Navigator.pushReplacementNamed(context, '/home');
                }
              }
            } catch (e) {
              print('Facebook 로그인 중 오류 발생: $e');
              // 에러 처리...
            } finally {
              setState(() => _isLoading = false);
            }
          },
          icon: FontAwesomeIcons.facebookF,
          text: "Facebook으로 계속하기",
          color: Color(0xFF1877F2),
          textColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String text,
    required Color color,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: borderColor ?? Colors.transparent,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Icon(
                icon,
                color: textColor,
                size: 20,
              ),
            ),
            Center(
              child: Text(
                text,
                style: GoogleFonts.notoSans(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "또는",
            style: GoogleFonts.notoSans(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildEmailLogin() {
    return TextButton(
      onPressed: () {
        // 이메일 로그인 화면으로 이동
        Navigator.pushNamed(context, '/email-login');
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        "이메일로 로그인하기",
        style: GoogleFonts.notoSans(
          color: Color(0xFFfa6386),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "계정이 없으신가요? ",
          style: GoogleFonts.notoSans(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/signup'),
          child: Text(
            "회원가입",
            style: GoogleFonts.notoSans(
              color: Color(0xFFfa6386),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}