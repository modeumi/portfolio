import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
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
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Icon(Icons.arrow_back_ios_new, size: 28, color: color_black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
              child: Text(profile.name ?? '이름 없음', style: black(24, FontWeight.w800)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 60),
              child: hasContent
                  ? ProjectContent(profile.content!)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: Center(child: Text('작성된 내용이 없습니다', style: custom(16, FontWeight.w400, font_grey))),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
