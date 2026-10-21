import 'package:flutter/material.dart';
import 'package:neu_trade/features/profile/presentation/widgets/stat.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../core/services/profile_services.dart';
import '../../domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final UserProfile profile;

  String get _initials {
    final words = profile.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    return words.length == 1
        ? words.first.characters.first.toUpperCase()
        : (words.first.characters.first + words.last.characters.first)
              .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ColorConstants.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.primaryColor.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: ColorConstants.primaryColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: ColorConstants.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 13, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'MSV: ${profile.studentId}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: ProfileServices()
                  .getUserPublicStats(userId: profile.userId)
                  .catchError((_) => null),
              builder: (context, snapshot) {
                final rating =
                    snapshot.data?['diem_trung_binh']?.toString() ?? '5.0';
                final count =
                    snapshot.data?['tong_danh_gia']?.toString() ?? '0';
                final cancelCount =
                    snapshot.data?['so_lan_huy_don']?.toString() ??
                    profile.cancelledOrderCount?.toString() ??
                    '0';
                final stats = [
                  Stat(value: '$rating★ ($count)', label: 'Đánh giá'),
                  Stat(value: cancelCount, label: 'Hủy đơn'),
                ];
                return Row(
                  children: [
                    Expanded(child: stats[0]),
                    Container(
                      height: 36,
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    Expanded(child: stats[1]),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
