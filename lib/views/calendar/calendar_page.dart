import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/views/calendar/widgets/calendar_view.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';
import 'package:utility/modal_widget.dart';
import 'package:utility/textstyle.dart';

class CalendarPage extends ConsumerStatefulWidget {
  final String previous;
  const CalendarPage({super.key, required this.previous});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> with RiverpodMixin {
  bool pageNavigeting = false;
  DateTime firstDate = DateTime(2020, 1, 0);
  DateTime lastDate = DateTime(2030, 12, 31);
  TextEditingController quick = TextEditingController();
  TextEditingController dailyQuick = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      layoutController.changeColor(true);
      if (widget.previous == 'homeCalendar') {
        calendarController.loadDailySchedule();
        context.push('/calendar_daily_schedule');
      }
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
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        decoration: BoxDecoration(color: pWhite),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 20,
              children: [
                InkWell(
                  onTap: () {
                    layoutController.tabBack(context);
                  },
                  child: SvgPicture.asset('images/top_back.svg', width: 40),
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    context.push('/calendar_search');
                  },
                  child: Icon(Icons.search, size: 30),
                ),
                InkWell(
                  onTap: () {
                    calendarController.changeCalendarDate(DateTime.now());
                  },
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 1.5, color: color_black),
                    ),
                    child: Center(child: Text('${DateTime.now().day}', style: black(16, FontWeight.w800))),
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                spacing: 30,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      DateTime targetDate = calendarState.targetDate;
                      DateTime now = DateTime.now();
                      DateTime prevDate = DateTime(targetDate.year, targetDate.month - 1, 1);
                      if (now.year == prevDate.year && now.month == prevDate.month) {
                        prevDate = now;
                      }
                      if (prevDate.isAfter(firstDate)) {
                        calendarController.changeCalendarDate(prevDate);
                      }
                    },
                    child: Icon(Icons.keyboard_arrow_left_sharp, size: 40),
                  ),
                  Text('${calendarState.targetDate.month}월', style: black(25, FontWeight.w700)),
                  GestureDetector(
                    onTap: () {
                      DateTime targetDate = calendarState.targetDate;
                      DateTime now = DateTime.now();
                      DateTime nextDate = DateTime(targetDate.year, targetDate.month + 1, 1);
                      if (now.year == nextDate.year && now.month == nextDate.month) {
                        nextDate = now;
                      }
                      if (nextDate.isBefore(lastDate)) {
                        calendarController.changeCalendarDate(nextDate);
                      }
                    },
                    child: Icon(Icons.keyboard_arrow_right_sharp, size: 40),
                  ),
                ],
              ),
            ),
            CalendarView(
              emptyScheduleAction: () {
                calendarController.changeEdit(false);
                calendarController.initAddSchedule();
                context.push('/calendar_add_schedule');
              },
              existScheduleAction: () async {
                await layoutController.withLoading(() async {
                  await calendarController.loadDailySchedule();
                });
                if (pageNavigeting) return;
                pageNavigeting = true;
                await context.push('/calendar_daily_schedule');
                pageNavigeting = false;
              },
              showScheduleLimit: false,
            ),

            if (!pageNavigeting)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
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
                                if (!layoutState.admin) {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        ModalWidget(width: 300, title: '권한', action: () {}, content: '해당 동작을 위한 권한이 없습니다.', select_button: true),
                                  );
                                  return;
                                }
                                await calendarController.addSchedule(data);
                                quick.clear();
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
              ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
