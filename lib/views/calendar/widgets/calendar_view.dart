import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/models/schedules_model.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/textstyle.dart';

class CalendarView extends ConsumerStatefulWidget {
  final VoidCallback emptyScheduleAction;
  final VoidCallback existScheduleAction;
  final bool showScheduleLimit;
  const CalendarView({super.key, required this.emptyScheduleAction, required this.existScheduleAction, required this.showScheduleLimit});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> with RiverpodMixin {
  DateTime firstDate = DateTime(2020, 1, 0);
  DateTime lastDate = DateTime(2030, 12, 31);
  DateTime now = DateTime.now();
  List<String> calendarHeader = ['일', '월', '화', '수', '목', '금', '토'];

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calendarController.setCalendarRows();
      layoutController.withLoading(() async {
        await calendarController.loadSchedule();
        await calendarController.getHoliday();
      });
    });
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

        bool limit = widget.showScheduleLimit && maxIndex > 0;
        Map<String, dynamic> cellData = {
          'rowIndex': limit ? 0 : rowIndex,
          'cellIndex': limit ? 0 : maxIndex,
          'model': i['model'],
          'length': limit ? 0 : i['date'].length,
        };

        for (var key in elementIndex.keys) {
          weekIndexInfo[key] = maxIndex + elementHeight;
        }

        returnData.add(cellData);
      }
      return returnData;
    }
    return [];
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            for (var i in calendarState.calendarRows.entries)
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
                                        width: cellWidth * i['length'],
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
                                          widget.emptyScheduleAction();
                                        } else {
                                          widget.existScheduleAction();
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
                                          color: date_to_string_yyyyMMdd('-', calendarState.targetDate) == element ? color_grey : Colors.transparent,
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
    );
  }
}
