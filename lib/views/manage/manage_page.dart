import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/controllers/login_controller.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:utility/color.dart';
import 'package:utility/modal_widget.dart';

class ManagePage extends ConsumerStatefulWidget {
  const ManagePage({super.key});

  @override
  ConsumerState<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends ConsumerState<ManagePage> with RiverpodMixin {
  bool permission = false;
  @override
  void initState() {
    // TODO: implement initState
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
      }
    });
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
                ],
              ),
            )
          : Container(),
    );
  }
}
