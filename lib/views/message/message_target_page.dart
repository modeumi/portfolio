import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/controllers/message_controller.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';
import 'package:utility/textstyle.dart';

class MessageTargetPage extends ConsumerStatefulWidget {
  const MessageTargetPage({super.key});

  @override
  ConsumerState<MessageTargetPage> createState() => _MessageTargetPageState();
}

class _MessageTargetPageState extends ConsumerState<MessageTargetPage> {
  TextEditingController search = TextEditingController();
  String before = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    search.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageControllerProvider);
    final controller = ref.read(messageControllerProvider.notifier);
    return Container(
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
                  child: SvgPicture.asset('images/top_back.svg', color: color_black, width: 35),
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
              child: CustomTextField(controller: search, hint: '대화를 시작할 닉네임 입력', maxLine: 1, hintColor: pBackGrey, maxLength: 15),
            ),
          ),
          Text('닉네임은 최대 15자이며, 이를 초과할 경우 15자로 자동 조정됩니다.', style: custom(18, FontWeight.w500, accent)),
          if (search.text != '')
            GestureDetector(
              onTap: () {
                controller.searchTarget(context, search.text);
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
                    child: Column(
                      children: [
                        // 대화 유저 목록 출력
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Center(child: Text('대화 대상이 없습니다.', style: black(25, FontWeight.w800))),
                ),
        ],
      ),
    );
  }
}
