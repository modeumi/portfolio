import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/controllers/layout_controller.dart';
import 'package:portfolio/controllers/message_controller.dart';
import 'package:portfolio/views/message/message_thumnail.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';
import 'package:utility/textstyle.dart';

class MessageListPage extends ConsumerStatefulWidget {
  const MessageListPage({super.key});

  @override
  ConsumerState<MessageListPage> createState() => _MessageListPageState();
}

class _MessageListPageState extends ConsumerState<MessageListPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var layoutController = ref.read(layoutControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      layoutController.changeColor(true);
      layoutController.withLoading(() async {
        await ref.read(messageControllerProvider.notifier).loadChatList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageControllerProvider);
    final controller = ref.read(messageControllerProvider.notifier);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(color: back_grey_2),
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(child: Text('채팅', style: custom(35, FontWeight.w800, secondary))),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(color: pWhite, borderRadius: BorderRadius.circular(20)),
                child: Stack(
                  children: [
                    if (messageState.targets.isNotEmpty)
                      Column(spacing: 10, children: [for (var i in messageState.targets) MessageThumnail(model: i)])
                    else
                      Center(child: Text('진행중인 채팅 내역이 없습니다.', style: grey(25, FontWeight.w500))),
                    Positioned(
                      bottom: 15,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          context.push('/message_target');
                        },
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pWhite,
                            boxShadow: [BoxShadow(offset: Offset(0, 3), color: color_grey, blurRadius: 4)],
                          ),
                          child: SvgPicture.asset('images/bubble.svg'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
