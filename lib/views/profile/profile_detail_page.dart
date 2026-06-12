import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/empty_state.dart';
import 'package:portfolio/views/profile/widgets/profile_photo_header.dart';
import 'package:portfolio/views/project/widgets/project_content.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

// 프로필 미리보기 (manage에서 항목 탭 시)
class ProfileDetailPage extends ConsumerStatefulWidget {
  const ProfileDetailPage({super.key});

  @override
  ConsumerState<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends ConsumerState<ProfileDetailPage> with RiverpodMixin {
  @override
  Widget build(BuildContext context) {
    final profile = profileState.profile;
    final bool hasContent = profile.content != null && profile.content!.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: pWhite),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.arrow_back_ios_new, size: 28, color: color_black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(profile.name ?? '이름 없음', style: black(18, FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            const ProfilePhotoHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 60),
              child: hasContent
                  ? ProjectContent(profile.content!)
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: EmptyState(icon: Icons.description_outlined, message: '작성된 내용이 없습니다'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
