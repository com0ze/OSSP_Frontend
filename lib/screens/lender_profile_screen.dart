import 'package:flutter/material.dart';
import '/extensions/theme_extension.dart';
import '/models/user.dart';

/// 사용자 정보 헤더 위젯 (프로필 화면 공통 사용)
class UserInfoHeader extends StatelessWidget {
  final User user;
  final String? email;

  const UserInfoHeader({super.key, required this.user, this.email});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 30,
                child: Text(user.name[0], style: const TextStyle(fontSize: 35)),
              ),
              const SizedBox(height: 10),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (email != null) ...[
                const SizedBox(height: 4),
                Text(
                  email!,
                  style: TextStyle(
                    fontSize: 10,
                    color: context.onSurfaceVariantColor,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(width: screenWidth * 0.10),
          Align(
            alignment: Alignment.centerRight,
            child: _StatItem(
              icon: Icon(Icons.favorite, color: context.heartColor),
              label: '매너 점수',
              value: user.score.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 사용자 통계 카드 위젯
class UserStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Icon icon;

  const UserStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: context.onSurfaceVariantColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: context.onSurfaceVariantColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final Icon icon;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: context.onSurfaceVariantColor),
        ),
      ],
    );
  }
}
