import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

class FieldLayout extends ConsumerStatefulWidget {
  final Widget child;
  const FieldLayout(this.child, {super.key});

  @override
  ConsumerState<FieldLayout> createState() => _FieldLayoutState();
}

class _FieldLayoutState extends ConsumerState<FieldLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pBackGrey,
      body: Center(
        child: Container(
          width: app_width * 3.5,
          height: app_height * 1.2,
          decoration: BoxDecoration(color: pWhite, borderRadius: BorderRadius.circular(15)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 1, color: color_black)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: black(22, FontWeight.w600),
                          children: [
                            TextSpan(text: 'Modeumi', style: custom(25, FontWeight.w800, pMainColor)),
                            TextSpan(text: '\'s'),
                            TextSpan(text: ' Portfolio'),
                          ],
                        ),
                      ),
                      GestureDetector(onTap: () => context.push('/'), child: Icon(Icons.close, size: 35)),
                    ],
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
