import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/loading_indicator.dart';
import 'package:utility/modal_widget.dart';
import 'package:utility/textstyle.dart';

class CalendarDaliySchedulePage extends ConsumerStatefulWidget {
  const CalendarDaliySchedulePage({super.key});

  @override
  ConsumerState<CalendarDaliySchedulePage> createState() => _CalendarDaliySchedulePageState();
}

class _CalendarDaliySchedulePageState extends ConsumerState<CalendarDaliySchedulePage> with RiverpodMixin {
  TextEditingController quick = TextEditingController();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: app_width,
      height: app_height,
      child: Stack(
        children: [
          Opacity(
            opacity: 0.6,
            child: GestureDetector(
              onTap: () {
                context.pop();
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(color: color_grey),
              ),
            ),
          ),
          Center(
            child: Container(
              width: app_width - 100,
              height: app_height - 350,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: pWhite),
              child: Column(
                spacing: 10,
                children: [
                  DottedBorder(
                    options: CustomPathDottedBorderOptions(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      color: color_black,
                      strokeWidth: 1,
                      dashPattern: [2, 4],
                      customPath: (size) => Path()
                        ..moveTo(0, size.height)
                        ..relativeLineTo(size.width, 0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 10,
                      children: [
                        Text('${calendarState.targetDate.day}', style: black(30, FontWeight.w700)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text('${getWeekdayLetter(calendarState.targetDate)}요일', style: black(20, FontWeight.w700)),
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            setState(() {
                              loading = true;
                              layoutController.withLoading(() async {
                                await calendarController.changeCalendarDate(calendarState.targetDate.add(Duration(days: -1)));
                                await calendarController.loadDailySchedule();
                              });
                              loading = false;
                            });
                          },
                          child: Icon(Icons.keyboard_arrow_left_rounded, size: 35, color: color_black),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              loading = true;
                              layoutController.withLoading(() async {
                                await calendarController.changeCalendarDate(calendarState.targetDate.add(Duration(days: 1)));
                                await calendarController.loadDailySchedule();
                              });
                              loading = false;
                            });
                          },
                          child: Icon(Icons.keyboard_arrow_right_rounded, size: 35, color: color_black),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(child: Text('음력 ${date_to_string_MMdd('kor', calendarState.lunarDate)}', style: grey(15, FontWeight.w600))),
                        InkWell(
                          onTap: () {
                            calendarController.changeEdit(false);
                            calendarController.initAddSchedule();
                            context.push('/calendar_add_schedule');
                          },
                          child: Icon(Icons.edit_calendar_outlined, color: color_black),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: loading
                        ? Center(child: LoadingIndicator(color: primary))
                        : SingleChildScrollView(
                            child: Column(
                              spacing: 20,
                              children: [
                                for (var i in calendarState.dailySchedules)
                                  if (i.date!.length > 1 || i.allDay == true)
                                    GestureDetector(
                                      onTap: () {
                                        calendarController.setSchedule(i);
                                        context.push('/calendar_detail');
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                        decoration: BoxDecoration(
                                          color: Color(i.colorCode!).withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(13),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              spacing: 15,
                                              children: [
                                                Flexible(
                                                  flex: 1,
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child: Icon(Icons.calendar_month_rounded, color: Color(i.colorCode!)),
                                                  ),
                                                ),
                                                Flexible(flex: 9, child: Text(i.title ?? '', style: black(22, FontWeight.w600))),
                                              ],
                                            ),
                                            Row(
                                              spacing: 15,
                                              children: [
                                                Flexible(flex: 1, child: Container(width: double.infinity)),
                                                Flexible(
                                                  flex: 9,
                                                  child: Text(
                                                    i.allDay ?? false
                                                        ? i.date!.length > 1
                                                              ? '${date_to_string_MMdd('kor', DateTime.parse(i.date!.first))} - ${date_to_string_MMdd('kor', DateTime.parse(i.date!.last))}'
                                                              : '하루 종일'
                                                        : '${date_to_string_MMdd('kor', DateTime.parse(i.date!.first))} ${reforme_time_short('m:', i.startTime!)} - ${date_to_string_MMdd('kor', DateTime.parse(i.date!.last))} ${reforme_time_short('m:', i.endTime!)}',
                                                    style: custom(16, FontWeight.w400, font_grey),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    GestureDetector(
                                      onTap: () {
                                        calendarController.setSchedule(i);
                                        context.push('/calendar_detail');
                                      },
                                      child: Column(
                                        children: [
                                          Row(
                                            spacing: 18,
                                            children: [
                                              Flexible(
                                                flex: 2,
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: Text(reforme_time_short(':', i.startTime!), style: black(18, FontWeight.w700)),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 1,
                                                child: Container(
                                                  decoration: BoxDecoration(color: Color(i.colorCode!), borderRadius: BorderRadius.circular(25)),
                                                  child: Text(' ', style: black(22, FontWeight.w500)),
                                                ),
                                              ),
                                              Flexible(flex: 9, child: Text(i.title!, style: black(22, FontWeight.w600))),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Flexible(flex: 2, child: SizedBox(width: double.infinity)),
                                              Flexible(flex: 1, child: SizedBox(width: double.infinity)),
                                              Flexible(
                                                flex: 9,
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.only(left: 5),
                                                  child: Text(
                                                    i.allDay ?? false
                                                        ? '하루 종일'
                                                        : '${reforme_time_short('m:', '${i.startTime}')} - ${reforme_time_short('m:', '${i.endTime}')}',
                                                    style: custom(16, FontWeight.w400, font_grey),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                              ],
                            ),
                          ),
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      Flexible(
                        flex: 5,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: back_grey_2),
                          height: 60,
                          child: Center(
                            child: CustomTextField(
                              controller: quick,
                              hint: '${date_to_string_MMdd('kor', calendarState.targetDate)} 일정 입력',
                              fontWeight: FontWeight.w600,
                              maxLine: 1,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double width = constraints.maxWidth;
                            return GestureDetector(
                              onTap: () async {
                                calendarController.initAddSchedule();
                                if (quick.text.trim().replaceAll(' ', '') != '') {
                                  Map<String, dynamic> data = {'title': quick.text, 'note': '', 'allDay': true};
                                  bool result = await calendarController.addSchedule(data);
                                  if (result) {
                                    calendarController.loadDailySchedule();
                                    quick.clear();
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          ModalWidget(title: '오류', action: () {}, content: '일정 등록에 실패하였습니다.\n잠시 후 다시 시도해주세요.', select_button: true),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                width: width,
                                height: width,
                                decoration: BoxDecoration(
                                  color: pWhite,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(offset: Offset(0, 5), blurRadius: 7, color: color_grey)],
                                ),
                                child: Center(child: Icon(Icons.add, size: 50, color: secondary)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
