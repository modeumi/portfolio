import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/core/widgets/custom_text_field.dart';
import 'package:portfolio/models/schedules_model.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/modal_widget.dart';
import 'package:utility/textstyle.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> with RiverpodMixin {
  bool pageNavigeting = false;
  DateTime firstDate = DateTime(2020, 1, 0);
  DateTime lastDate = DateTime(2030, 12, 31);
  TextEditingController quick = TextEditingController();
  TextEditingController dailyQuick = TextEditingController();
  Map<int, List<String>> calendarRows = {};
  DateTime now = DateTime.now();
  List<String> calendarHeader = ['일', '월', '화', '수', '목', '금', '토'];

  @override
  void initState() {
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

  DateTime otherMonth(bool type, int day) {
    int month = calendarState.targetDate.month + (type ? 1 : -1);
    DateTime returnDate = DateTime(calendarState.targetDate.year, month, day);
    return returnDate;
  }

  void setCalendarRows() {
    calendarRows.clear();
    DateTime beforeMonthLastDay = DateTime(calendarState.targetDate.year, calendarState.targetDate.month, 0);
    DateTime monthFirstDay = DateTime(calendarState.targetDate.year, calendarState.targetDate.month, 1);
    DateTime monthLastDay = DateTime(calendarState.targetDate.year, calendarState.targetDate.month + 1, 0);

    int week = 1;

    int firstWeekday = monthFirstDay.weekday % 7; // Dart는 월요일=1, 일요일=7이라 0으로 맞춤

    // 첫째주 지난달 일자 채우기
    if (week == 1) {
      calendarRows[week] = [];
      int calendarFirstDay = beforeMonthLastDay.day - firstWeekday + 1;
      for (int i = calendarFirstDay; i <= beforeMonthLastDay.day; i++) {
        String strDate = date_to_string_yyyyMMdd('-', otherMonth(false, i));
        calendarRows[week]!.add(strDate);
      }
    }

    // 이번달 달력 채우기
    for (int day = 1; day <= monthLastDay.day; day++) {
      if (calendarRows[week] == null) {
        calendarRows[week] = [];
      }
      DateTime date = DateTime(calendarState.targetDate.year, calendarState.targetDate.month, day);
      String strDate = date_to_string_yyyyMMdd('-', date);
      calendarRows[week]!.add(strDate);
      if (calendarRows[week]!.length == 7) {
        week++;
      }
    }

    // 마지막주 다음달 채우기
    if (calendarRows[calendarRows.keys.last]!.length != 7) {
      int nextMonth = 1;
      while (calendarRows[calendarRows.keys.last]!.length < 7) {
        String strDate = date_to_string_yyyyMMdd('-', otherMonth(true, nextMonth));
        calendarRows[calendarRows.keys.last]!.add(strDate);
        nextMonth++;
      }
    }

    setState(() {});
  }

  Color daysFontColor(String day) {
    Color returnColor = color_black;

    DateTime targetDate = calendarState.targetDate;
    DateTime date = DateTime.parse(day);

    if (calendarState.holiday.contains(day)) {
      returnColor = color_red;
    } else if (date.month != targetDate.month) {
      String weekLetter = getWeekdayLetter(date);
      if (weekLetter == '토') {
        returnColor = Color(0xFFDCEAF7);
      } else if (weekLetter == '일') {
        returnColor = Color(0xFFF3CBC9);
      } else {
        returnColor = color_grey;
      }
    } else {
      String weekLetter = getWeekdayLetter(date);
      if (weekLetter == '토') {
        returnColor = color_blue;
      } else if (weekLetter == '일') {
        returnColor = color_red;
      } else if (date_to_string_yyyyMMdd('-', now) == day) {
        returnColor = pWhite;
      } else {
        returnColor = color_black;
      }
    }

    return returnColor;
  }

  List<Map<String, dynamic>> weekSchedule(List<String> week) {
    List<Map<String, dynamic>> filtered = [];
    for (var i in calendarState.schedules.entries) {
      // print(i); : MapEntry(1763339250119: ScheduleModel(date: [2025-11-01, 2025-11-02, 2025-11-03], startTime: 00:00, endTime: 18:30, allDay: false, title: ex1, note: asdasd, colorCode: 4286154444))
      List<String> range = i.value.date.where((element) => week.contains(element)).toList();
      if (range.isNotEmpty) {
        filtered.add({'date': range, 'model': i.value});
      }
    }
    filtered.sort((a, b) => (b['model'].date as List).length.compareTo((a['model'].date as List).length));
    if (filtered.isNotEmpty) {
      Map<String, int> weekIndexInfo = {};
      for (var i in week) {
        weekIndexInfo[i] = 0;
      }
      List<Map<String, dynamic>> returnData = [];

      for (var i in filtered) {
        DateTime firstDate = DateTime.parse(i['date'].first);
        Map<String, int> elementIndex = {};
        for (var j in i['date']) {
          if (weekIndexInfo.containsKey(j)) {
            elementIndex[j] = weekIndexInfo[j]!;
          }
        }

        int maxIndex = elementIndex.values.reduce((a, b) => a > b ? a : b);
        int rowIndex = firstDate.weekday == 7 ? 0 : firstDate.weekday;

        int titleByte = utf8.encode(i['model'].title).length;

        int elementHeight = i['date'].length > 1
            ? 25
            : titleByte > 13
            ? 32
            : 18;

        Map<String, dynamic> cellData = {'rowIndex': rowIndex, 'cellIndex': maxIndex, 'model': i['model'], 'length': i['date'].length};

        for (var key in elementIndex.keys) {
          weekIndexInfo[key] = maxIndex + elementHeight;
        }
        returnData.add(cellData);
      }
      return returnData;
    }
    return [];
  }

  List<ScheduleModel> dayScheduleFilter(String day) {
    List<ScheduleModel> result = [];

    for (var i in calendarState.schedules.entries) {
      if (i.value.date.contains(day)) {
        result.add(i.value);
      }
    }

    return result;
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
                  child: Icon(Icons.keyboard_arrow_left, color: color_black, size: 40),
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
                        setCalendarRows();
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
                        setCalendarRows();
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
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double cellWidth = constraints.maxWidth / 7;
                              List<Map<String, dynamic>> data = weekSchedule(i.value);
                              return Stack(
                                children: [
                                  for (var i in data)
                                    Positioned(
                                      left: cellWidth * i['rowIndex'],
                                      top: i['cellIndex'],
                                      child: Container(
                                        margin: EdgeInsets.only(top: 30),
                                        child: i['model'].date.length > 1 || i['model'].allDay == true
                                            ? Container(
                                                width: cellWidth * i['length'],
                                                height: 20,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Color(i['model'].colorCode)),
                                                child: Center(
                                                  child: Text(i['model'].title, style: white(14, FontWeight.w500), overflow: TextOverflow.ellipsis),
                                                ),
                                              )
                                            : Container(
                                                width: cellWidth,
                                                padding: EdgeInsets.symmetric(horizontal: 3),
                                                decoration: BoxDecoration(
                                                  border: Border(left: BorderSide(width: 3, color: Color(i['model'].colorCode))),
                                                ),
                                                child: Text(
                                                  i['model'].title,
                                                  style: custom(14, FontWeight.w500, color_black, null, null, 1),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      for (var element in i.value)
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (date_to_string_yyyyMMdd('-', calendarState.targetDate) == element) {
                                                List<ScheduleModel> schedule = dayScheduleFilter(element);
                                                if (schedule.isEmpty) {
                                                  calendarController.changeEdit(false);
                                                  calendarController.initAddSchedule();
                                                  context.push('/calendar_add_schedule');
                                                } else {
                                                  await layoutController.withLoading(() async {
                                                    await calendarController.loadDailySchedule();
                                                  });
                                                  if (pageNavigeting) return;
                                                  pageNavigeting = true;
                                                  await context.push('/calendar_daily_schedule');
                                                  pageNavigeting = false;
                                                }
                                              } else {
                                                calendarController.changeCalendarDate(DateTime.parse(element));
                                              }
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              padding: EdgeInsets.symmetric(vertical: 2),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  width: 1,
                                                  color: date_to_string_yyyyMMdd('-', calendarState.targetDate) == element
                                                      ? color_grey
                                                      : Colors.transparent,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 25,
                                                    height: 25,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      color: date_to_string_yyyyMMdd('-', now) == element ? color_black : pWhite,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${int.parse(element.split('-').last)}',
                                                        style: custom(17, FontWeight.w600, daysFontColor(element)),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(child: SizedBox()),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
                                bool result = await calendarController.addSchedule(data);
                                if (result) {
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
              ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
