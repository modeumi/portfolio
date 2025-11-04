// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/controllers/message_controller.dart';
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

class _MessageThumnailState extends ConsumerState<MessageThumnail> {
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final controller = ref.read(messageControllerProvider.notifier);
    return GestureDetector(
      onTap: () {
        controller.setTarget(widget.model);
        if (widget.model.lock!) {
          bool validPassword = true;
          showDialog(
            context: context,
            builder: (context) => ModalWidget(
              title: '비밀번호 입력',
              contentWidget: Column(
                children: [
                  CustomTextField(controller: password, hint: '비밀번호 입력', obscure: true),
                  !validPassword ? Text('data') : Text('data'),
                ],
              ),
              width: 400,
              action: () {
                setState(() {
                  validPassword = controller.checkPassword(password.text);
                });
              },
            ),
          );
        } else {}
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
                Text(widget.model.name!, style: black(22, FontWeight.w700)),
                if (widget.model.lock!) Icon(Icons.lock, color: color_grey, size: 20),
                Spacer(),
                Text(date_to_string_yyyyMMdd('kor', widget.model.lastDate), style: grey(18, FontWeight.w500)),
              ],
            ),
            Text(widget.model.lock! ? widget.model.lastContent! : '비공개 채팅입니다.', style: grey(18, FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
