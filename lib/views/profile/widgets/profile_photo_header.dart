import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';

// 자기소개 상단에 들어가는 원형 프로필 사진 헤더
class ProfilePhotoHeader extends StatelessWidget {
  const ProfilePhotoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [backSurface, pWhite],
        ),
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: pWhite, width: 4),
            boxShadow: [BoxShadow(offset: const Offset(0, 8), blurRadius: 20, color: secondary.withValues(alpha: 0.25))],
            image: const DecorationImage(image: AssetImage('images/profile.png'), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
