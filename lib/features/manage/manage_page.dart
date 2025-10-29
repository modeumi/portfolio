import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/features/login/login_controller.dart';
import 'package:portfolio/features/manage/manage_controller.dart';
import 'package:utility/color.dart';
import 'package:utility/modal_widget.dart';

class ManagePage extends ConsumerStatefulWidget {
  const ManagePage({super.key});

  @override
  ConsumerState<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends ConsumerState<ManagePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      User? user = ref.watch(loginControllerProvider).user;
      if (user == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('접근 불가'),
            content: Text('권한이 없어 페이지에 접근하실 수 없습니다.\n로그인 페이지로 돌아갑니다.'),
            actions: [TextButton(onPressed: () => context.go('/login'), child: const Text('확인'))],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final manageState = ref.watch(manageControllerProvider);
    final controller = ref.read(manageControllerProvider.notifier);
    return Container(
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
                    showDialog(
                      context: context,
                      builder: (context) => ModalWidget(
                        title: '로그아웃',
                        content: '로그아웃 하시겠습니까?',
                        action: () {
                          ref.read(loginControllerProvider.notifier).logout(context);
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
    );
  }
}
