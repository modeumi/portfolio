import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
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
  Map<int, List<int>> calendarRows = {};
  DateTime now = DateTime.now();
  List<String> calendarHeader = ['일', '월', '화', '수', '목', '금', '토'];
  List<String> holiday = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      layoutController.changeColor(true);
      layoutController.withLoading(() async {
        await calendarController.loadSchedule();
        await calendarController.getHoliday();
      });
      setCalendarRows();
    });
  }

  void setCalendarRows() {
    DateTime beforeMonthLastDay = DateTime(calendarState.targetDate.year, calendarState.targetDate.month, 0);
    DateTime monthFirstDay = DateTime(calendarState.targetDate.year, calendarState.targetDate.month, 1);
    DateTime monthLastDay = DateTime(calendarState.targetDate.year, calendarState.targetDate.month + 1, 0);

    int week = 1;

    int firstWeekday = monthFirstDay.weekday % 7; // Dart는 월요일=1, 일요일=7이라 0으로 맞춤

    if (week == 1) {
      calendarRows[week] = [];
      int calendarFirstDay = beforeMonthLastDay.day - firstWeekday + 1;
      for (int i = calendarFirstDay; i <= beforeMonthLastDay.day; i++) {
        calendarRows[week]!.add(i);
      }
    }
    // int monthDay = 1;
    for (int day = 1; day <= monthLastDay.day; day++) {
      if (calendarRows[week] == null) {
        calendarRows[week] = [];
      }
      calendarRows[week]!.add(day);
      if (calendarRows[week]!.length == 7) {
        week++;
      }
    }
    if (calendarRows[calendarRows.keys.last]!.length != 7) {
      int nextMonth = 1;
      while (calendarRows[calendarRows.keys.last]!.length < 7) {
        calendarRows[calendarRows.keys.last]!.add(nextMonth);
        nextMonth++;
      }
    }
    setState(() {});
  }

  Color daysFontColor(int index, int day) {
    DateTime targetDate = calendarState.targetDate;
    Color returnColor = color_black;
    DateTime date = DateTime(targetDate.year, targetDate.month, day);

    if (index == 1) {
      int firstWeekLastDay = calendarRows[index]!.last;
      DateTime previousMonth = DateTime(targetDate.year, targetDate.month - 1, day);

      if (getWeekdayLetter(previousMonth) == '일') {
        returnColor = Color(0xFFF3CBC9);
      } else if (day > firstWeekLastDay) {
        returnColor = color_grey;
      }
    } else if (index == calendarRows.keys.last) {
      int lastWeekLastDay = DateTime(targetDate.year, targetDate.month + 1, 0).day;
      int lastDayIndex = calendarRows[index]!.indexOf(lastWeekLastDay);
      DateTime nextMonth = DateTime(targetDate.year, targetDate.month + 1, day);
      if (getWeekdayLetter(nextMonth) == '토') {
        returnColor = Color(0xFFDCEAF7);
      } else if (calendarRows[index]!.indexOf(day) > lastDayIndex) {
        returnColor = color_grey;
      }
    } else {
      String dayLetter = getWeekdayLetter(date);
      if (dayLetter == '일') {
        returnColor = color_red;
      } else if (dayLetter == '토') {
        returnColor = color_blue;
      }
    }
    return returnColor;
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
            child: SizedBox(
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var i in calendarHeader)
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Center(
                              child: Text(
                                i,
                                style: custom(
                                  17,
                                  FontWeight.w500,
                                  calendarHeader.first == i
                                      ? color_red
                                      : calendarHeader.last == i
                                      ? color_blue
                                      : color_black,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (var i in calendarRows.entries)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(width: 1, color: color_grey)),
                        ),
                        child: Row(
                          children: [
                            for (var element in i.value)
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(width: 1, color: calendarState.targetDate.day == element ? color_black : pWhite),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: now.day == element ? color_black : pWhite,
                                        ),
                                        child: Center(child: Text('$element', style: custom(17, FontWeight.w600, color_black))),
                                      ),
                                      Expanded(
                                        child: Container(width: double.infinity, height: double.infinity),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
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
