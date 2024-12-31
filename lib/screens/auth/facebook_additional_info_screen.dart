import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/profile_util.dart';

class FacebookAdditionalInfoScreen extends StatefulWidget {
  final UserCredential userCredential;
  final Map<String, dynamic> facebookUserData;

  FacebookAdditionalInfoScreen({
    required this.userCredential,
    required this.facebookUserData,
  });

  @override
  _FacebookAdditionalInfoScreenState createState() => _FacebookAdditionalInfoScreenState();
}

class _FacebookAdditionalInfoScreenState extends State<FacebookAdditionalInfoScreen> {
  final _birthDateController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedRegion = 'Vietnam';
  String _selectedSkinType = 'Da thường';
  List<String> _selectedSkinConditions = [];
  String _selectedIcon = '😊';

  final _firestoreService = FirestoreService();

  // ProfileUtils에서 옵션들 가져오기
  final genderOptions = ProfileUtils.genderOptions;
  final regionOptions = ProfileUtils.regionOptions;
  final skinTypeOptions = ProfileUtils.skinTypeOptions;
  final skinConditionsOptions = ProfileUtils.skinConditionsOptions;
  final iconOptions = ProfileUtils.iconOptions;

  void _completeSignup() async {
    if (!_validateInputs()) return;

    try {
      DateTime? parsedDate;
      try {
        parsedDate = DateFormat('yyyy-MM-dd').parse(_birthDateController.text.trim());
      } catch (e) {
        _showErrorDialog('입력 오류', '올바른 생년월일 형식이 아닙니다.');
        return;
      }

      // Facebook에서 받아온 정보와 추가 입력 정보를 합쳐서 UserModel 생성
      final newUser = UserModel(
        email: widget.userCredential.user?.email ?? '',
        username: widget.facebookUserData['name'] ?? '',
        gender: _selectedGender,
        birthDate: parsedDate,
        region: _selectedRegion,
        skinType: _selectedSkinType,
        skinConditions: _selectedSkinConditions,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profileImageUrl: widget.userCredential.user?.photoURL ?? '',
        icon: _selectedIcon,
        role: 'user',
        grade: 'Bronze',
        uid: widget.userCredential.user?.uid ?? '',
      );

      // Firestore에 사용자 정보 저장
      await _firestoreService.createUser(widget.userCredential.user!.uid, newUser);

      // 메인 화면으로 이동
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showErrorDialog('오류 발생', e.toString());
    }
  }

  bool _validateInputs() {
    if (_birthDateController.text.isEmpty) {
      _showErrorDialog('입력 오류', '생년월일을 입력해주세요.');
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
                  _buildAdditionalInfoForm(),
                  const SizedBox(height: 24),
                  _buildCompleteButton(),
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
          Text(
            'Review Này',
            style: GoogleFonts.dancingScript(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color(0xFFfa6386),
            ),
            textAlign: TextAlign.center,
          ),
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 2),
            child: Text(
              "추가 정보 입력",
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
              "피부 관리 여정을 시작하기 위해\n몇 가지 추가 정보가 필요해요",
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

  Widget _buildAdditionalInfoForm() {
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
          // 페이스북 프로필 정보 표시
          _buildFacebookProfileInfo(),
          const SizedBox(height: 24),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 24),
          // 추가 정보 입력 폼
          _buildDateField("생년월일", _birthDateController, Icons.cake),
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

// 페이스북 프로필 정보를 보여주는 위젯
  Widget _buildFacebookProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "페이스북 프로필 정보",
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        // 프로필 이미지와 이름을 가로로 배치
        Row(
          children: [
            // 프로필 이미지
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200], // 배경색 추가
              ),
              child: widget.facebookUserData['picture']?['data']?['url'] != null ||
                  widget.userCredential.user?.photoURL != null
                  ? ClipOval(
                child: Image.network(
                  widget.facebookUserData['picture']?['data']?['url'] ??
                      widget.userCredential.user?.photoURL!,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(
                Icons.person,
                size: 40,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(width: 16),
            // 이름과 이메일을 세로로 배치
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.facebookUserData['name'] ?? '이름 없음',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.userCredential.user?.email ?? '이메일 없음',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 페이스북으로 가져온 정보임을 알리는 텍스트
        Text(
          "* 페이스북 계정에서 가져온 정보입니다",
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, IconData icon) {
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
            readOnly: true,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    controller.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // [이전 코드의 _buildDropdown, _buildSkinTypeSection, _buildIconSelector 메서드들을 그대로 사용]
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

  Widget _buildCompleteButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _completeSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFfa6386),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          "완료",
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    super.dispose();
  }
}