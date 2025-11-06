import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:utility/color.dart';

class CalendarAddSchedule extends ConsumerStatefulWidget {
  const CalendarAddSchedule({super.key});

  @override
  ConsumerState<CalendarAddSchedule> createState() => _CalendarAddScheduleState();
}

class _CalendarAddScheduleState extends ConsumerState<CalendarAddSchedule> with RiverpodMixin {
  TextEditingController title = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      decoration: BoxDecoration(color: color_white),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: color_grey)),
            ),
            child: Row(
              spacing: 20,
              children: [
                Expanded(
                  child: CustomTextField(controller: title, hint: '제목', maxLine: 1, action: () {}, fontWeight: FontWeight.w500),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
