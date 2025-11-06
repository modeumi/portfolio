import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/views/calendar/widgets/calendar_builder.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';
import 'package:utility/textstyle.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> with RiverpodMixin {
  DateTime firstDate = DateTime(2020, 1, 0);
  DateTime lastDate = DateTime(2030, 12, 31);
  TextEditingController quick = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      layoutController.changeColor(true);
    });
  }

  double getWeeksInMonth(DateTime month) {
    // 해당 달의 첫째 날
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);

    // 해당 달의 마지막 날
    DateTime lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // 전체일수
    int totalDays = lastDayOfMonth.day;

    // 달력 첫주 비활성 일자 계산
    int outsideDay = (firstDayOfMonth.weekday % 7);

    // 첫 주의 빈칸 포함해서 총 일수 계산
    final totalCells = totalDays + outsideDay;

    // 주(행) 수 계산 (7일 단위로 나누기)
    final weekCount = (totalCells / 7).ceil();

    if (weekCount == 6) {
      return 120;
    } else if (weekCount == 4) {
      return 180;
    } else {
      return 145;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      decoration: BoxDecoration(color: pWhite),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 20,
            children: [
              GestureDetector(
                onTap: () {
                  layoutController.tabBack(context);
                },
                child: Icon(Icons.keyboard_arrow_left, color: color_black, size: 40),
              ),
              Spacer(),
              GestureDetector(onTap: () {}, child: Icon(Icons.search, size: 30)),
              GestureDetector(
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
          Expanded(
            child: TableCalendar(
              focusedDay: calendarState.targetDate,
              firstDay: firstDate,
              lastDay: lastDate,
              locale: 'ko-KR',
              headerVisible: false,
              daysOfWeekHeight: 30,
              rowHeight: getWeeksInMonth(calendarState.targetDate),
              calendarStyle: CalendarStyle(isTodayHighlighted: false),
              pageAnimationEnabled: false,
              availableGestures: AvailableGestures.none,
              onDaySelected: (selectedDay, focusedDay) {
                String strSelect = date_to_string_yyyyMMdd('-', selectedDay);
                String strFocused = date_to_string_yyyyMMdd('-', calendarState.targetDate);
                if (strSelect == strFocused) {
                  context.push('/calendar_add_schedule');
                  // homeController.changeCalendarDate(selectedDay);
                } else {
                  calendarController.changeCalendarDate(selectedDay);
                }
              },
              calendarBuilders: CalendarBuilders(
                dowBuilder: (context, day) {
                  switch (day.weekday) {
                    case DateTime.sunday:
                      return Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.horizontal(left: Radius.circular(5))),
                        child: Center(child: Text('일', style: custom(17, FontWeight.w700, color_red))),
                      );
                    case DateTime.saturday:
                      return Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.horizontal(right: Radius.circular(5))),
                        child: Center(child: Text('토', style: custom(17, FontWeight.w700, color_blue))),
                      );
                    default:
                      return Center(child: Text(['월', '화', '수', '목', '금'][day.weekday - 1], style: black(17, FontWeight.w700)));
                  }
                },
                defaultBuilder: (context, day, focusedDay) {
                  return CalendarBuildContainer(false, focusedDay, day);
                },
                outsideBuilder: (context, day, focusedDay) {
                  return CalendarBuildContainer(true, focusedDay, day);
                },
                selectedBuilder: (context, day, focusedDay) {
                  return CalendarBuildContainer(false, focusedDay, day);
                },
              ),
            ),
          ),
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
                        onTap: () {},
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
    );
  }
}
