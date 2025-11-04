import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/controllers/layout_controller.dart';
import 'package:portfolio/controllers/message_controller.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';
import 'package:utility/modal_widget.dart';
import 'package:utility/textstyle.dart';

class MessageChatPage extends ConsumerStatefulWidget {
  const MessageChatPage({super.key});

  @override
  ConsumerState<MessageChatPage> createState() => _MessageChatPageState();
}

class _MessageChatPageState extends ConsumerState<MessageChatPage> {
  TextEditingController content = TextEditingController();
  TextEditingController password = TextEditingController();
  bool lock = false;
  bool showMessage = false;
  bool admin = false;
  bool answer = false;
  String message = '비밀번호를 입력해주세요.';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        admin = ref.read(messageControllerProvider.notifier).checkAdmin();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageControllerProvider);
    final controller = ref.read(messageControllerProvider.notifier);
    final layoutController = ref.read(layoutControllerProvider.notifier);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: pWhite),
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              spacing: 20,
              children: [
                GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: SvgPicture.asset('images/top_back.svg', color: secondary),
                ),
                Expanded(
                  child: Text(messageState.target!.name ?? '대상오류', style: custom(25, FontWeight.w700, secondary), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 5,
              children: [
                if (admin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 5,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            answer = !answer;
                            showMessage = false;
                            password.clear();
                          });
                        },
                        child: Icon(answer ? Icons.check_box : Icons.check_box_outline_blank_rounded, color: answer ? pBackBlack : color_grey),
                      ),
                      Text('답변', style: grey(18, FontWeight.w500)),
                    ],
                  ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          lock = !lock;
                        });
                      },
                      child: Icon(lock ? Icons.check_box : Icons.check_box_outline_blank_rounded, color: lock ? pBackBlack : color_grey),
                    ),
                    Text('비공개', style: grey(18, FontWeight.w500)),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ModalWidget(
                            title: '안내',
                            content: '비공개를 선택 시 해당 채팅에 진입 할 때 비밀번호를 입력해야 열람 및 채팅 입력이 가능합니다.',
                            width: 400,
                            action: () {},
                            select_button: true,
                          ),
                        );
                      },
                      child: Icon(Icons.info, color: color_grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 메세지 출력 라인
          Expanded(child: SingleChildScrollView(child: Column())),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: Row(
              spacing: 5,
              children: [
                Text('비밀번호', style: grey(18, FontWeight.w500)),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ModalWidget(
                        title: '안내',
                        content: '첫 채팅 시 등록한 비밀번호로 이후 채팅 입력 시 비밀번호가 일치해야 입력이 가능합니다.',
                        width: 400,
                        action: () {},
                        select_button: true,
                      ),
                    );
                  },
                  child: Icon(Icons.info, color: color_grey),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 2, color: color_grey)),
                      // borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: password,
                            hint: '비밀번호를 입력해주세요.',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            maxLine: 1,
                            obscure: true,
                            action: () {
                              setState(() {
                                showMessage = false;
                              });
                            },
                          ),
                        ),
                        if (showMessage) Text(message, style: custom(18, FontWeight.w400, color_red)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              spacing: 15,
              children: [
                GestureDetector(onTap: () {}, child: SvgPicture.asset('images/image.svg', width: 40)),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    decoration: BoxDecoration(color: back_grey_2, borderRadius: BorderRadius.circular(30)),
                    child: CustomTextField(controller: content, hint: '메세지를 입력해주세요.', fontSize: 19, fontWeight: FontWeight.w500),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      if (password.text == '') {
                        showMessage = true;
                      } else {
                        showMessage = false;
                      }
                    });
                    if (content.text != '' && password.text != '') {
                      String result = '';
                      await layoutController.withLoading(() async {
                        result = await controller.sendChat(content.text, password.text, lock, answer);
                      });
                      if (result == 'pass') {
                        content.clear();
                        await layoutController.withLoading(() async {
                          await controller.loadChat(messageState.target!.name!);
                          await controller.loadChatList();
                        });
                      } else if (result == 'password') {
                        showDialog(
                          context: context,
                          builder: (context) => ModalWidget(
                            title: '비밀번호 오류',
                            content: '비밀번호가 일치하지 않습니다.\n확인 후 다시 시도해주세요.',
                            width: 400,
                            action: () {},
                            select_button: true,
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              ModalWidget(title: '오류', content: '일시적인 오류가 발생하였습니다.\n잠시 후 다시 시도해주세요.', width: 400, action: () {}, select_button: true),
                        );
                      }
                    }
                  },
                  child: SvgPicture.asset('images/send.svg', width: 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
