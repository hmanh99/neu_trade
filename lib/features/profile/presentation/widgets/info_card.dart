import 'package:flutter/material.dart';
import 'package:neu_trade/core/constants/color_constants.dart';
import 'package:neu_trade/features/profile/domain/entities/user_profile.dart';
import 'package:neu_trade/features/profile/presentation/widgets/profile_field.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.profile});

  final UserProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorConstants.borderLightColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileField(
            icon: Icons.badge_outlined,
            label: 'Mã sinh viên',
            value: profile.studentId,
          ),
          const Divider(color: ColorConstants.dividerColor),
          ProfileField(
            icon: Icons.person_outline,
            label: 'Họ và tên',
            value: profile.fullName,
          ),
          const Divider(color: ColorConstants.dividerColor),
          ProfileField(
            icon: Icons.phone_outlined,
            label: 'Số điện thoại',
            value: profile.phone,
          ),
          const Divider(color: ColorConstants.dividerColor),
          ProfileField(
            icon: Icons.alternate_email,
            label: 'Email sinh viên',
            value: profile.email,
          ),
        ],
      ),
    );
  }
}
