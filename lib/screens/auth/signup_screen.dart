import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/profile_util.dart';

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

  String _selectedGender = 'Male';
  String _selectedRegion = 'Vietnam';
  String _selectedSkinType = 'Da thường';
  List<String> _selectedSkinConditions = [];
  String _selectedIcon = '😊';



  // ProfileUtils에서 옵션들 가져오기
  final genderOptions = ProfileUtils.genderOptions;
  final regionOptions = ProfileUtils.regionOptions;
  final skinTypeOptions = ProfileUtils.skinTypeOptions;
  final skinConditionsOptions = ProfileUtils.skinConditionsOptions;
  final iconOptions = ProfileUtils.iconOptions;

  final _authService = AuthService();
  final _firestoreService = FirestoreService();  // 추가

  void _signUp() async {
    if (!_validateInputs()) return;

    try {
      User? user = await _authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        final newUser = UserModel.fromEmailSignup(
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          gender: _selectedGender,
          age: int.parse(_ageController.text.trim()),
          region: _selectedRegion,
          skinType: _selectedSkinType,
          skinConditions: _selectedSkinConditions,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          profileImageUrl: '',
          icon: _selectedIcon,
          role: 'user',
          grade: 'Bronze',
          uid: '',
        );

        await _firestoreService.createUser(user.uid, newUser);
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _showErrorDialog('Lỗi đăng ký', e.toString());
    }
  }

  bool _validateInputs() {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _ageController.text.isEmpty) {
      _showErrorDialog('입력 오류', '모든 필수 항목을 입력해주세요.');
      return false;
    }
    return true;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildSignupForm(),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Color(0xFFfa6386)),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Review Này',
                  style: GoogleFonts.dancingScript(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFfa6386),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // 좌우 대칭을 위한 투명한 아이콘 버튼
              SizedBox(width: 48),  // IconButton의 기본 너비만큼 공간 확보
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 2),
            child: Text(
              "Tạo tài khoản mới",
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Text(
              "Bắt đầu hành trình làm đẹp của bạn ngay hôm nay",
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Color(0xFFfa6386).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Email", _emailController, Icons.email),
          const SizedBox(height: 16),
          _buildTextField("Mật khẩu", _passwordController, Icons.lock, isPassword: true),
          const SizedBox(height: 16),
          _buildTextField("Tên người dùng", _usernameController, Icons.person),
          const SizedBox(height: 16),
          _buildTextField("Tuổi", _ageController, Icons.cake, isNumber: true),
          const SizedBox(height: 16),
          _buildDropdown(),
          const SizedBox(height: 16),
          _buildSkinTypeSection(),
          const SizedBox(height: 16),
          _buildIconSelector(),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool isPassword = false,
        bool isNumber = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: GoogleFonts.notoSans(),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Giới tính",
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: genderOptions.map((gender) => DropdownMenuItem(
              value: gender['key'],
              child: Text(gender['label']!, style: GoogleFonts.notoSans()),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedGender = value;
                });
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Khu vực",
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedRegion,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: regionOptions.map((region) => DropdownMenuItem(
              value: region['key'],
              child: Text(region['label']!, style: GoogleFonts.notoSans()),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRegion = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }



// _buildSkinTypeSection() 메서드를 수정
  Widget _buildSkinTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Loại da(피부 타입)",
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedSkinType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: skinTypeOptions.map((type) => DropdownMenuItem(
              value: type['key'],
              child: Text(type['label']!, style: GoogleFonts.notoSans()),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSkinType = value!;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Tình trạng da(피부 상태)",
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: MultiSelectDialogField(
            items: skinConditionsOptions.map((condition) => MultiSelectItem<String>(
              condition['key']!,
              condition['label']!,
            )).toList(),
            title: Text('Chọn tình trạng da'),
            selectedColor: Color(0xFFfa6386),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            buttonIcon: Icon(Icons.add_circle_outline, color: Color(0xFFfa6386)),
            buttonText: Text(
              _selectedSkinConditions.isEmpty
                  ? 'Vui lòng chọn tình trạng da'
                  : '${_selectedSkinConditions.length} tình trạng được chọn',
              style: GoogleFonts.notoSans(color: Colors.grey[600]),
            ),
            onConfirm: (values) {
              setState(() {
                _selectedSkinConditions = values.cast<String>();
              });
            },
            chipDisplay: MultiSelectChipDisplay(
              onTap: (value) {
                setState(() {
                  _selectedSkinConditions.remove(value);
                });
              },
              chipColor: Color(0xFFfa6386).withOpacity(0.1),
              textStyle: GoogleFonts.notoSans(
                color: Color(0xFFfa6386),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Biểu tượng(아이콘)",
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: iconOptions.length,
          itemBuilder: (context, index) {
            final icon = iconOptions[index];
            final isSelected = _selectedIcon == icon;
            return GestureDetector(
              onTap: () => setState(() => _selectedIcon = icon),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(0xFFfa6386).withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Color(0xFFfa6386) : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurple.shade700],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFfa6386),
              shadowColor: Color(0xFFfa6386),
              // backgroundColor: Colors.transparent,
              // shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              "Đăng ký",
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Bạn đã có tài khoản? ",
              style: GoogleFonts.notoSans(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text(
                "Login",
                style: GoogleFonts.notoSans(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}