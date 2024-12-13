// lib/screens/product/widgets/review_filter_sheet.dart <- lib/screens/widgets/product_review_section.dart의 필터 시트임

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/profile_util.dart';


class ReviewFilterSheet extends StatefulWidget {
  final String? selectedSkinType;
  final List<String> selectedConditions;
  final Function(String?, List<String>) onApply;

  const ReviewFilterSheet({
    required this.selectedSkinType,
    required this.selectedConditions,
    required this.onApply,
    Key? key,
  }) : super(key: key);

  static void show(BuildContext context, {
    required String? selectedSkinType,
    required List<String> selectedConditions,
    required Function(String?, List<String>) onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewFilterSheet(
        selectedSkinType: selectedSkinType,
        selectedConditions: selectedConditions.toList(),
        onApply: onApply,
      ),
    );
  }

  @override
  State<ReviewFilterSheet> createState() => _ReviewFilterSheetState();
}

class _ReviewFilterSheetState extends State<ReviewFilterSheet> {
  late String? _selectedSkinType;
  late List<String> _selectedConditions;

  @override
  void initState() {
    super.initState();
    _selectedSkinType = widget.selectedSkinType;
    _selectedConditions = widget.selectedConditions.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    title: 'Loại da', // Skin Type
                    options: ProfileUtils.skinTypeOptions,
                    selectedValue: _selectedSkinType,
                    onSelect: (value) => setState(() => _selectedSkinType = value),
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 24),
                  _buildMultiFilterSection(
                    title: 'Tình trạng da', // Skin Conditions
                    options: ProfileUtils.skinConditionsOptions,
                    selectedValues: _selectedConditions,
                    onSelect: _toggleCondition,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          ),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Lọc đánh giá', // Filter Reviews
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Đặt lại', // Reset
              style: GoogleFonts.notoSans(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<Map<String, String>> options,
    required String? selectedValue,
    required Function(String?) onSelect,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option['key'];
            return _buildFilterOption(
              label: option['label']!,
              isSelected: isSelected,
              onTap: () => onSelect(isSelected ? null : option['key']),
              color: color,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultiFilterSection({
    required String title,
    required List<Map<String, String>> options,
    required List<String> selectedValues,
    required Function(String) onSelect,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option['key']);
            return _buildFilterOption(
              label: option['label']!,
              isSelected: isSelected,
              onTap: () => onSelect(option['key']!),
              color: color,
              showCheckmark: true,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    bool showCheckmark = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheckmark && isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.check, size: 16, color: color),
              ),
            Text(
              label,
              style: GoogleFonts.notoSans(
                color: isSelected ? color : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          widget.onApply(_selectedSkinType, _selectedConditions);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Áp dụng', // Apply
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _toggleCondition(String condition) {
    setState(() {
      if (_selectedConditions.contains(condition)) {
        _selectedConditions.remove(condition);
      } else {
        _selectedConditions.add(condition);
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedSkinType = null;
      _selectedConditions.clear();
    });
  }
}