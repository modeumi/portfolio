import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/models/message_target_model.dart';
import 'package:utility/color.dart';
import 'package:utility/modal_widget.dart';
import 'package:utility/textstyle.dart';

class MessageSearchField extends ConsumerStatefulWidget {
  final MessageTargetModel model;
  const MessageSearchField({super.key, required this.model});

  @override
  ConsumerState<MessageSearchField> createState() => _MessageSearchFieldState();
}

class _MessageSearchFieldState extends ConsumerState<MessageSearchField> with RiverpodMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.model.lock == true) {
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
                      validPassword = messageController.checkPassword(password.text, widget.model);
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
          if (result == true) {
            messageController.setSearchTarget(context, widget.model.name!);
          } else {
            return;
          }
        } else {
          messageController.setSearchTarget(context, widget.model.name!);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: color_grey)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(widget.model.name ?? '', style: black(23, FontWeight.w800)),
            Text('최근 대화 : ${widget.model.lastDate ?? ''}', style: grey(17, FontWeight.w400), textAlign: TextAlign.end),
          ],
        ),
      ),
    );
  }
}
