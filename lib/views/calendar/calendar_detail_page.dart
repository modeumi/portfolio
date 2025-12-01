import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/modal_widget.dart';
import 'package:utility/textstyle.dart';

class CalendarDetailPage extends ConsumerStatefulWidget {
  const CalendarDetailPage({super.key});

  @override
  ConsumerState<CalendarDetailPage> createState() => _CalendarDetailPageState();
}

class _CalendarDetailPageState extends ConsumerState<CalendarDetailPage> with RiverpodMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: app_width,
      height: app_height,
      decoration: BoxDecoration(color: backSurface),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 70, 30, 0),
              decoration: BoxDecoration(
                color: pWhite,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          context.pop();
                        },
                        child: SvgPicture.asset('images/top_back.svg', width: 50),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1, color: color_grey)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(calendarState.schedule.title ?? '', style: black(28, FontWeight.w500))),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Color(calendarState.schedule.colorCode!)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(5, 15, 20, 15),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1, color: color_grey)),
                    ),
                    child: Column(
                      spacing: 10,
                      children: [
                        Row(
                          spacing: 30,
                          children: [
                            Icon(Icons.access_time, size: 25),
                            Expanded(
                              child: Text(
                                '${date_to_string_MMdd('kor', calendarState.schedule.startDate!)} (${getWeekdayLetter(DateTime.parse(calendarState.schedule.startDate!))})',
                                style: black(22, FontWeight.w500),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            if (calendarState.schedule.allDay ?? false) Icon(Icons.arrow_forward, size: 30),
                            Expanded(
                              child: Text(
                                '${date_to_string_MMdd('kor', calendarState.schedule.endDate!)} (${getWeekdayLetter(DateTime.parse(calendarState.schedule.endDate!))})',
                                style: black(22, FontWeight.w500),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        if ((calendarState.schedule.allDay ?? false) == false)
                          Row(
                            children: [
                              Flexible(flex: 1, child: SizedBox(width: double.infinity)),
                              Flexible(flex: 9, child: Center(child: Icon(Icons.arrow_forward, size: 30))),
                            ],
                          ),
                        if ((calendarState.schedule.allDay ?? false) == false)
                          Row(
                            spacing: 30,
                            children: [
                              SizedBox(width: 25, height: 1),
                              Expanded(
                                child: Text(
                                  reforme_time_short('m:', calendarState.schedule.startTime!),
                                  style: black(22, FontWeight.w500),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  reforme_time_short('m:', calendarState.schedule.endTime!),
                                  style: black(22, FontWeight.w500),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(date_calculation(DateTime.parse(calendarState.schedule.startDate!)), style: custom(20, FontWeight.w500, font_grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  calendarController.changeEdit(true);
                  context.push('/calendar_add_schedule');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(color: backSurface),
                  child: Column(
                    children: [
                      Icon(Icons.edit_outlined, size: 30, color: secondary),
                      Text('편집', style: custom(18, FontWeight.w500, secondary)),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  if (!layoutState.admin) {
                    showDialog(
                      context: context,
                      builder: (context) => ModalWidget(width: 300, title: '권한', action: () {}, content: '해당 동작을 위한 권한이 없습니다.', select_button: true),
                    );
                    return;
                  }
                  layoutController.changeDialogState(true);
                  bool? result = await showDialog(
                    context: context,
                    builder: (context) => ModalWidget(
                      title: '일정 삭제',
                      width: 300,
                      contentWidget: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Text('해당 일정을 삭제하시겠습니까?', style: black(20, FontWeight.w500)),
                      ),
                      action: () {
                        Navigator.pop(context, true);
                        layoutController.changeDialogState(false);
                      },
                      cancle: () {
                        layoutController.changeDialogState(false);
                      },
                    ),
                  );
                  if (result == true) {
                    await layoutController.withLoading(() async {
                      await calendarController.deleteSchedule();
                    });
                    context.pop();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(color: backSurface),
                  child: Column(
                    children: [
                      Icon(Icons.delete_forever_outlined, size: 30, color: secondary),
                      Text('삭제', style: custom(18, FontWeight.w500, secondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
