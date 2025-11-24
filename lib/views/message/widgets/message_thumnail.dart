import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/models/message_target_model.dart';

import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/modal_widget.dart';
import 'package:utility/textstyle.dart';

class MessageThumnail extends ConsumerStatefulWidget {
  final MessageTargetModel model;
  const MessageThumnail({super.key, required this.model});

  @override
  ConsumerState<MessageThumnail> createState() => _MessageThumnailState();
}

class _MessageThumnailState extends ConsumerState<MessageThumnail> with RiverpodMixin {
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // final messageState = ref.watch(messageControllerProvider);
    // final controller = ref.read(messageControllerProvider.notifier);
    // final LayoutController = ref.
    return GestureDetector(
      onTap: () {
        messageController.setTarget(widget.model);
        password.clear();

        if (widget.model.lock! && !layoutState.admin) {
          bool validPassword = true;
          layoutController.changeDialogState(true);
          showDialog(
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setState) {
                return ModalWidget(
                  title: '비밀번호 입력',
                  contentWidget: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                      validPassword = messageController.checkPassword(password.text);
                      if (validPassword) {
                        layoutController.changeDialogState(false);
                        Navigator.pop(context);
                        context.push('/message_chat');
                      }
                    });
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
        } else {
          context.push('/message_chat');
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: color_grey)),
        ),
        child: Column(
          spacing: 3,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              children: [
                Text(widget.model.name!, style: black(20, FontWeight.w700)),
                if (widget.model.lock!) Icon(Icons.lock, color: color_grey, size: 20),
                Spacer(),
                Text(date_to_string_yyyyMMdd('kor', widget.model.lastDate), style: grey(18, FontWeight.w500)),
              ],
            ),
            Text(
              widget.model.lock! ? '비공개 채팅입니다.' : widget.model.lastContent!,
              style: grey(18, FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
