import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/controllers/login_controller.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/views/manage/widgets/project_item.dart';
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
        manageController.getProjects();
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
    if (projects.isEmpty) {
      return Center(child: Text('등록된 프로젝트가 없습니다', style: custom(18, FontWeight.w400, font_grey)));
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
      itemCount: projects.length,
      separatorBuilder: (context, index) => SizedBox(height: 15),
      itemBuilder: (context, index) => ProjectItem(model: projects[index]),
    );
  }

  Widget _profileTab() {
    return Center(child: Text('프로필', style: custom(18, FontWeight.w400, font_grey)));
  }
}
