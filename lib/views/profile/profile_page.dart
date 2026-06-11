import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/models/profile_model.dart';
import 'package:portfolio/views/profile/widgets/profile_photo_header.dart';
import 'package:portfolio/views/project/widgets/project_content.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

// mobile view 내정보 → 현재 선택된 프로필의 자기소개를 출력
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with RiverpodMixin {
  bool loading = true;
  ProfileModel? profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final model = await profileController.loadSelected();
      if (!mounted) return;
      setState(() {
        profile = model;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasContent = profile?.content != null && profile!.content!.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: pWhite),
      child: loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : !hasContent
          ? Center(child: Text('등록된 프로필이 없습니다', style: custom(16, FontWeight.w400, font_grey)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const ProfilePhotoHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 60),
                    child: ProjectContent(profile!.content!),
                  ),
                ],
              ),
            ),
    );
  }
}
