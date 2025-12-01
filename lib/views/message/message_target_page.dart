import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/models/message_target_model.dart';
import 'package:portfolio/views/message/widgets/message_search_field.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';
import 'package:utility/modal_widget.dart';
import 'package:utility/textstyle.dart';

class MessageTargetPage extends ConsumerStatefulWidget {
  const MessageTargetPage({super.key});

  @override
  ConsumerState<MessageTargetPage> createState() => _MessageTargetPageState();
}

class _MessageTargetPageState extends ConsumerState<MessageTargetPage> with RiverpodMixin {
  TextEditingController search = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      messageController.searchTarget('');
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
      child: Container(
        decoration: BoxDecoration(color: back_grey_2),
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Column(
          spacing: 15,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                spacing: 15,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pop();
                    },
                    child: SvgPicture.asset('images/top_back.svg', color: color_black),
                  ),
                  Text('대화 대상 선택', style: black(26, FontWeight.w900)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                decoration: BoxDecoration(color: color_grey, borderRadius: BorderRadius.circular(30)),
                child: CustomTextField(
                  controller: search,
                  hint: '대화를 시작할 닉네임 입력',
                  maxLine: 1,
                  hintColor: pBackGrey,
                  maxLength: 15,
                  action: () {
                    messageController.searchTarget(search.text);
                  },
                ),
              ),
            ),
            Text('닉네임은 최대 15자이며, 이를 초과할 경우 15자로 자동 조정됩니다.', style: custom(18, FontWeight.w500, accent)),
            if (search.text != '')
              GestureDetector(
                onTap: () async {
                  bool existing = false;
                  bool adminName = false;
                  if (search.text.toLowerCase() == 'modeumi') {
                    adminName = true;
                    layoutController.changeDialogState(true);
                    showDialog(
                      context: context,
                      builder: (context) => ModalWidget(
                        title: '이름 오류',
                        content: '해당 이름은 사용하실 수 없습니다.\n다른 이름으로 다시 시도해주세요.',
                        width: 400,
                        action: () {
                          layoutController.changeDialogState(false);
                        },
                        select_button: true,
                      ),
                    );
                    return;
                  }

                  MessageTargetModel target = MessageTargetModel();
                  for (var i in messageState.targets) {
                    if (i.name == search.text && i.lock == true) {
                      setState(() {
                        existing = true;
                        target = i;
                      });
                    }
                  }
                  if (existing) {
                    TextEditingController password = TextEditingController();
                    bool validPassword = true;
                    bool? result = await showDialog(
                      context: context,
                      builder: (context) => StatefulBuilder(
                        builder: (context, setState) {
                          return ModalWidget(
                            title: '비밀번호 입력',
                            contentWidget: Container(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                spacing: 10,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('해당 이름의 채팅은 잠겨있습니다.\n입장하기위해 비밀번호를 입력주세요.', style: black(18, FontWeight.w500)),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(width: 1, color: color_grey),
                                    ),
                                    child: CustomTextField(controller: password, hint: '비밀번호 입력', obscure: true, maxLine: 1),
                                  ),
                                  validPassword ? Text('') : Text('비밀번호가 일치하지 않습니다', style: custom(18, FontWeight.w400, color_red)),
                                ],
                              ),
                            ),
                            width: 400,
                            action: () {
                              setState(() {
                                validPassword = messageController.checkPassword(password.text, target);
                              });
                              if (validPassword) {
                                layoutController.changeDialogState(false);
                                Navigator.pop(context, true);
                              }
                            },
                            cancle: () {
                              layoutController.changeDialogState(false);
                            },
                            submitButtonContent: '확인',
                            cancleButtonContent: '취소',
                          );
                        },
                      ),
                    );
                    if (result != true) {
                      return;
                    }
                  }

                  if (!adminName) {
                    messageController.setSearchTarget(context, search.text);
                  }
                },
                child: Container(
                  constraints: BoxConstraints(maxHeight: double.infinity),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 3),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.5, color: secondary),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                      Flexible(
                        child: Text(search.text, style: custom(20, FontWeight.w500, secondary), overflow: TextOverflow.ellipsis, maxLines: 1),
                      ),
                      Text('(으)로 대화 시작', style: custom(20, FontWeight.w500, secondary), maxLines: 1),
                    ],
                  ),
                ),
              ),
            messageState.searchTargets.isNotEmpty
                ? Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(color: pWhite, borderRadius: BorderRadius.circular(20)),
                      child: Column(spacing: 10, children: [for (var i in messageState.searchTargets) MessageSearchField(model: i)]),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: Center(child: Text('대화 대상이 없습니다.', style: black(25, FontWeight.w800))),
                  ),
          ],
        ),
      ),
    );
  }
}
