import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/views/calendar/widgets/calendar_builder.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';
import 'package:utility/textstyle.dart';

class HomeCalendar extends ConsumerStatefulWidget {
  const HomeCalendar({super.key});

  @override
  ConsumerState<HomeCalendar> createState() => _HomeCalendarState();
}

class _HomeCalendarState extends ConsumerState<HomeCalendar> with RiverpodMixin {
  DateTime firstDate = DateTime(2020, 1, 0);
  DateTime lastDate = DateTime(2030, 12, 31);

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
      return 62;
    } else if (weekCount == 4) {
      return 94;
    } else {
      return 75;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(color: pWhite, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              spacing: 6,
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
                  child: Icon(Icons.keyboard_arrow_left_sharp, size: 30),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text('${calendarState.targetDate.month}월', style: black(16, FontWeight.w800)),
                ),
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
                  child: Icon(Icons.keyboard_arrow_right_sharp, size: 30),
                ),
                Spacer(),
                GestureDetector(onTap: () {}, child: Icon(Icons.add, size: 30)),
                GestureDetector(
                  onTap: () {
                    calendarController.changeCalendarDate(DateTime.now());
                  },
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 1, color: pBackBlack2),
                    ),
                    child: Center(child: Text('${DateTime.now().day}', style: black(16, FontWeight.w500))),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              child: TableCalendar(
                locale: 'ko-KR',
                focusedDay: calendarState.targetDate,
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2030, 12, 31),
                headerVisible: false,
                daysOfWeekHeight: 30,
                pageAnimationEnabled: false,
                availableGestures: AvailableGestures.none,
                rowHeight: getWeeksInMonth(calendarState.targetDate),
                calendarStyle: CalendarStyle(isTodayHighlighted: false),
                onDaySelected: (selectedDay, focusedDay) {
                  // if (selectedDay == focusedDay) {
                  // homeController.changeCalendarDate(selectedDay);
                  // } else {
                  calendarController.changeCalendarDate(selectedDay);
                  // }
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
                    return calendarScheduleBuild(false, focusedDay, day, calendarState.schedules);
                  },
                  outsideBuilder: (context, day, focusedDay) {
                    return calendarScheduleBuild(true, focusedDay, day, calendarState.schedules);
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return calendarScheduleBuild(false, focusedDay, day, calendarState.schedules);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
