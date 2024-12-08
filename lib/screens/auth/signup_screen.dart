import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedGender = 'Male'; // 기본값
  String _selectedRegion = 'Vietnam'; // 기본값
  String _selectedSkinType = 'Normal'; // 피부 타입 단일 선택
  List<String> _selectedSkinConditions = []; // 피부 상태 복수 선택
  String _selectedIcon = '😊'; // 기본 아이콘/이모티콘

  final _authService = AuthService();

  // 피부 상태 리스트
  final List<Map<String, String>> _skinConditionsOptions = [
    {'key': 'acne', 'label': '여드름'},
    {'key': 'redness', 'label': '홍조'},
    {'key': 'wrinkles', 'label': '주름'},
    {'key': 'spots', 'label': '잡티'},
  ];

  // 아이콘/이모티콘 리스트
  final List<String> _iconOptions = [
    '👩', // 여성
    '👨', // 남성
    '👶', // 아기
    '🧑‍🎨', // 아티스트
    '👩‍🔧', // 기술자
    '💄', // 립스틱 (화장품)
    '💅', // 매니큐어
    '👗', // 드레스
    '👒', // 모자
    '👜', // 핸드백
  ];

  void _signUp() async {
    try {
      // Firebase Authentication으로 계정 생성
      User? user = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // Firestore에 사용자 정보 저장
        final newUser = UserModel(
          id: user.uid,
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          gender: _selectedGender,
          age: int.parse(_ageController.text.trim()),
          region: _selectedRegion,
          skinType: _selectedSkinType, // 단일 선택된 피부 타입 저장
          skinConditions: _selectedSkinConditions, // 복수 선택된 피부 상태 저장
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          profileImageUrl: '',
          icon: _selectedIcon, // 사용자가 선택한 아이콘 저장
          role: 'user', // 사용자 역할 (기본값: 'user')
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(newUser.toFirestore());

        // 회원가입 성공 -> 로그인 화면으로 이동
        Navigator.pushNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Sign-up failed: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Create Your Account",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Let’s get started with your beauty journey.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildInputCard(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField("Email", _emailController, TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField("Password", _passwordController, TextInputType.text, obscureText: true),
            const SizedBox(height: 16),
            _buildTextField("Username", _usernameController, TextInputType.text),
            const SizedBox(height: 16),
            _buildTextField("Age", _ageController, TextInputType.number),
            const SizedBox(height: 16),
            _buildDropdown("Gender", _selectedGender, ['Male', 'Female', 'Other'],
                    (value) => setState(() => _selectedGender = value!)),
            const SizedBox(height: 16),
            _buildDropdown("Region", _selectedRegion, ['Vietnam', 'Korea'],
                    (value) => setState(() => _selectedRegion = value!)),
            const SizedBox(height: 16),
            _buildDropdown("Skin Type", _selectedSkinType, ['Oily', 'Dry', 'Combination', 'Sensitive', 'Normal'],
                    (value) => setState(() => _selectedSkinType = value!)),
            const SizedBox(height: 16),
            MultiSelectDialogField(
              items: _skinConditionsOptions
                  .map((condition) => MultiSelectItem<String>(
                condition['key']!,
                condition['label']!,
              ))
                  .toList(),
              title: const Text('피부 상태'),
              selectedColor: Colors.deepPurple,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurple, width: 1),
              ),
              buttonText: const Text(
                '피부 상태 선택',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onConfirm: (values) {
                setState(() {
                  _selectedSkinConditions = List<String>.from(values);
                });
              },
            ),
            const SizedBox(height: 16),
            _buildIconSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Icon',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _iconOptions.length,
          itemBuilder: (context, index) {
            final icon = _iconOptions[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIcon = icon; // 선택한 아이콘 업데이트
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedIcon == icon
                      ? Colors.deepPurple.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedIcon == icon ? Colors.deepPurple : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
