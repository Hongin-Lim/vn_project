// lib/screens/review/widgets/user_info_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';
import '../../../utils/grade_utils.dart';

class UserInfoCard extends StatelessWidget {
  final String userId;
  final _firestoreService = FirestoreService();

  UserInfoCard({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _firestoreService.loadUserData(userId),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildUserAvatar(user),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserInfo(user),
                        const SizedBox(height: 8),
                        _buildSkinInfo(user),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(UserModel? user) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.indigo.withOpacity(0.1),
          backgroundImage: user?.profileImageUrl.isNotEmpty == true
              ? NetworkImage(user!.profileImageUrl)
              : null,
          child: user?.profileImageUrl.isEmpty == true
              ? _getAvatarChild(user)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              getGradeIcon(user?.grade ?? ''),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget? _getAvatarChild(UserModel? user) {
    if (user?.icon.isNotEmpty == true) {
      return Text(
        user!.icon,
        style: const TextStyle(fontSize: 32),
      );
    }
    return Icon(
      Icons.person_outline_rounded,
      size: 32,
      color: Colors.indigo[400],
    );
  }

  Widget _buildUserInfo(UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user?.username ?? 'Người dùng ẩn danh',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (user != null) ...[
          const SizedBox(height: 4),
          Text(
            '${user.region} · ${user.gender} · ${user.age}세',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSkinInfo(UserModel? user) {
    if (user == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildInfoChip(
          label: user.skinType,
          color: Colors.indigo,
        ),
        ...user.skinConditions.map(
          (condition) => _buildInfoChip(
            label: condition,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSans(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
