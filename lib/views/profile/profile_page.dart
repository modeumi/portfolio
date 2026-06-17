import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/empty_state.dart';
import 'package:portfolio/core/widgets/loading_view.dart';
import 'package:portfolio/models/profile_model.dart';
import 'package:portfolio/views/profile/widgets/profile_photo_header.dart';
import 'package:portfolio/views/project/widgets/project_content.dart';

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
      // 휴대폰 안쪽 표시: 흰 배경에 맞춰 상태바/네비 아이콘을 어둡게
      layoutController.changeColor(true);
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

    return Padding(
      // 상단 상태바 / 하단 네비 영역을 제외한 영역에만 내용 배치 (safe area)
      padding: EdgeInsets.only(top: statusBarHeight, bottom: navBarHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: pWhite),
        child: loading
            ? const LoadingView()
            : !hasContent
            ? const EmptyState(icon: Icons.badge_outlined, message: '등록된 프로필이 없습니다')
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const ProfilePhotoHeader(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 10, 22, 40),
                      child: ProjectContent(profile!.content!),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
