import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/profile_util.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userModel;

  const EditProfileScreen({Key? key, required this.userModel})
      : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _birthDateController;
  late String _selectedGender;
  late String _selectedRegion;
  late String _selectedSkinType;
  late List<String> _selectedSkinConditions;
  late String _selectedIcon;
  bool _isLoading = false;

  // ProfileUtils에서 옵션들 가져오기
  final genderOptions = ProfileUtils.genderOptions;
  final regionOptions = ProfileUtils.regionOptions;
  final skinTypeOptions = ProfileUtils.skinTypeOptions;
  final skinConditionsOptions = ProfileUtils.skinConditionsOptions;
  final iconOptions = ProfileUtils.iconOptions; // 아이콘 옵션 사용

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userModel.username);
    _birthDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.userModel.birthDate),
    );
    _selectedGender = widget.userModel.gender;
    _selectedRegion = widget.userModel.region;
    _selectedSkinType = widget.userModel.skinType;
    _selectedSkinConditions = List.from(widget.userModel.skinConditions);
    _selectedIcon = widget.userModel.icon;
  }

  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user != null) {
        // 업데이트할 데이터 준비
        DateTime? parsedDate;
        try {
          parsedDate = DateFormat('yyyy-MM-dd').parse(_birthDateController.text.trim());
        } catch (e) {
          // 날짜 파싱 실패 처리
          print('날짜 형식이 올바르지 않습니다: ${e.toString()}');
          return;
        }

        final updateData = {
          'username': _usernameController.text.trim(),
          'birthDate': Timestamp.fromDate(parsedDate),
          'gender': _selectedGender,
          'region': _selectedRegion,
          'skinType': _selectedSkinType,
          'skinConditions': _selectedSkinConditions,
          'icon': _selectedIcon,
        };

        // FirestoreService를 통해 업데이트
        await _firestoreService.updateUser(user.uid, updateData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cập nhật thông tin thành công',
              style: GoogleFonts.notoSans(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
              Colors.white,
              Colors.grey[50]!,
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
                  _buildEditForm(),
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
              SizedBox(width: 48),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 2),
            child: Text(
              "Chỉnh sửa thông tin",
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
              "Cập nhật thông tin cá nhân của bạn",
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

  Widget _buildEditForm() {
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
          _buildTextField("Tên người dùng", _usernameController, Icons.person),
          const SizedBox(height: 16),
          _buildDateField("Ngày sinh", _birthDateController, Icons.cake), // 수정된 부분
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

// 날짜 선택을 위한 새로운 위젯 메서드 추가
  Widget _buildDateField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: controller.text.isEmpty
                  ? DateTime.now()
                  : DateFormat('yyyy-MM-dd').parse(controller.text),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.text = DateFormat('yyyy-MM-dd').format(picked);
            }
          },
        ),
      ),
      readOnly: true, // 직접 입력 방지
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
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
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: genderOptions
                .map((gender) => DropdownMenuItem(
                      value: gender['key'],
                      child:
                          Text(gender['label']!, style: GoogleFonts.notoSans()),
                    ))
                .toList(),
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
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: regionOptions
                .map((region) => DropdownMenuItem(
                      value: region['key'],
                      child:
                          Text(region['label']!, style: GoogleFonts.notoSans()),
                    ))
                .toList(),
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
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: skinTypeOptions
                .map((type) => DropdownMenuItem(
                      value: type['key'],
                      child:
                          Text(type['label']!, style: GoogleFonts.notoSans()),
                    ))
                .toList(),
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
            initialValue: _selectedSkinConditions,
            items: skinConditionsOptions
                .map((condition) => MultiSelectItem<String>(
                      condition['key']!,
                      condition['label']!,
                    ))
                .toList(),
            title: Text('Chọn tình trạng da'),
            selectedColor: Color(0xFFfa6386),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            buttonIcon:
                Icon(Icons.add_circle_outline, color: Color(0xFFfa6386)),
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
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFfa6386),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    "Lưu thay đổi",
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Hủy",
            style: GoogleFonts.notoSans(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}
