import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/features/layout/layout_controller.dart';
import 'package:portfolio/features/message/message_controller.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';
import 'package:utility/textstyle.dart';

class MessagePage extends ConsumerStatefulWidget {
  const MessagePage({super.key});

  @override
  ConsumerState<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends ConsumerState<MessagePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(layoutControllerProvider.notifier).changeColor(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageState = ref.watch(messageControllerProvider);
    final controller = ref.read(messageControllerProvider.notifier);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 55),
      decoration: BoxDecoration(color: back_grey_2),
      child: Column(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(child: Text('메세지', style: custom(35, FontWeight.w800, secondary))),
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
                    Column(children: [
                        
                      ],
                    ),
                    Positioned(
                      bottom: 15,
                      right: 0,
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
// Container(
//   padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//   child: Row(
//     children: [
//       GestureDetector(
//         onTap: () {
//           Navigator.pop(context);
//         },
//         child: SvgPicture.asset('images/back.svg', color: color_black),
//       ),
//     ],
//   ),
// ),