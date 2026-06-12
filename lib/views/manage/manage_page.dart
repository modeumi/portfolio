import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/controllers/login_controller.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/views/manage/widgets/project_item.dart';
import 'package:portfolio/views/profile/widgets/profile_item.dart';
import 'package:utility/color.dart';
import 'package:utility/modal_widget.dart';
import 'package:utility/textstyle.dart';

class ManagePage extends ConsumerStatefulWidget {
  const ManagePage({super.key});

  @override
  ConsumerState<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends ConsumerState<ManagePage> with RiverpodMixin, TickerProviderStateMixin {
  bool permission = false;
  bool projectsLoading = true;
  bool profilesLoading = true;
  late final TabController tabController = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        layoutController.changeDialogState(true);
        showDialog(
          context: context,
          builder: (context) => ModalWidget(
            title: '접근 불가',
            content: '권한이 없어 페이지에 접근하실 수 없습니다.\n로그인 페이지로 돌아갑니다.',
            width: 400,
            action: () {
              layoutController.changeDialogState(false);
              context.go('/login');
            },
            cancle: () {
              layoutController.changeDialogState(false);
            },
            select_button: true,
          ),
        );
      } else {
        setState(() {
          permission = true;
        });
        manageController.getProjects().then((_) {
          if (mounted) setState(() => projectsLoading = false);
        });
        profileController.getProfiles().then((_) {
          if (mounted) setState(() => profilesLoading = false);
        });
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: layoutState.dialogOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (layoutState.dialogOpen) {
          layoutController.changeDialogState(false);
        }
      },
      child: permission
          ? Container(
              decoration: BoxDecoration(color: pWhite),
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        GestureDetector(
                          onTap: () {
                            layoutController.changeDialogState(true);
                            showDialog(
                              context: context,
                              builder: (context) => ModalWidget(
                                title: '로그아웃',
                                content: '로그아웃 하시겠습니까?',
                                width: 300,
                                action: () {
                                  Navigator.pop(context);
                                  layoutController.changeDialogState(false);
                                  ref.read(loginControllerProvider.notifier).logout(context);
                                },
                                cancle: () {
                                  layoutController.changeDialogState(false);
                                },
                              ),
                            );
                          },
                          child: Icon(Icons.logout, size: 35, color: color_black),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: tabController,
                    labelColor: secondary,
                    unselectedLabelColor: font_grey,
                    indicatorColor: secondary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: black(20, FontWeight.w700),
                    unselectedLabelStyle: custom(20, FontWeight.w500, font_grey),
                    tabs: const [
                      Tab(text: '프로젝트'),
                      Tab(text: '프로필'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        _projectTab(),
                        _profileTab(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(),
    );
  }

  Widget _projectTab() {
    final projects = manageState.projectList;
    return Stack(
      children: [
        if (projectsLoading)
          Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: secondary))
        else if (projects.isEmpty)
          Center(child: Text('등록된 프로젝트가 없습니다', style: custom(18, FontWeight.w400, font_grey)))
        else
          ListView.separated(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 90),
            itemCount: projects.length,
            separatorBuilder: (context, index) => SizedBox(height: 15),
            itemBuilder: (context, index) => ProjectItem(model: projects[index]),
          ),
        // 하단: 프로젝트 추가 버튼
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Center(
            child: GestureDetector(
              onTap: () {
                manageController.newProject();
                context.push('/project_write');
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: secondary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(offset: Offset(0, 4), color: pBackGrey2, blurRadius: 10)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Icon(Icons.add, color: pWhite, size: 24),
                    Text('프로젝트 추가', style: white(18, FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileTab() {
    final profiles = profileState.profileList;
    final int checkedCount = profileState.checked.length;
    return Stack(
      children: [
        if (profilesLoading)
          Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: secondary))
        else if (profiles.isEmpty)
          Center(child: Text('등록된 프로필이 없습니다', style: custom(18, FontWeight.w400, font_grey)))
        else
          ListView.separated(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 90),
            itemCount: profiles.length,
            separatorBuilder: (context, index) => SizedBox(height: 15),
            itemBuilder: (context, index) => ProfileItem(model: profiles[index]),
          ),
        // 하단: 프로필 추가 + 복사(체크 시)
        Positioned(
          left: 0,
          right: 0,
          bottom: 20,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                if (checkedCount > 0)
                  GestureDetector(
                    onTap: () => profileController.copyChecked(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      decoration: BoxDecoration(
                        color: pWhite,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: secondary, width: 1.5),
                        boxShadow: [BoxShadow(offset: Offset(0, 4), color: pBackGrey2, blurRadius: 10)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          Icon(Icons.copy_rounded, color: secondary, size: 22),
                          Text('복사 ($checkedCount)', style: custom(18, FontWeight.w700, secondary)),
                        ],
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    profileController.newProfile();
                    context.push('/profile_write');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: secondary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(offset: Offset(0, 4), color: pBackGrey2, blurRadius: 10)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Icon(Icons.add, color: pWhite, size: 24),
                        Text('프로필 추가', style: white(18, FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
