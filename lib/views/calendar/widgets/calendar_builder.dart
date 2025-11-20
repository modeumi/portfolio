import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/textstyle.dart';

Widget calendarScheduleBuild(bool outside, DateTime focusedDay, DateTime day) {
  DateTime now = DateTime.now();

  String strFocusedDay = date_to_string_yyyyMMdd('-', focusedDay);
  String strDay = date_to_string_yyyyMMdd('-', day);
  String strToday = date_to_string_yyyyMMdd('-', now);

  bool select = strDay == strFocusedDay;
  bool saturday = day.weekday == DateTime.saturday;
  bool sunday = day.weekday == DateTime.sunday;
  bool today = strToday == strDay;
  Map<String, dynamic> multiSchedule = {};
  Map<String, dynamic> singleSchedule = {};

  return FractionallySizedBox(
    widthFactor: 1,
    heightFactor: 1,
    child: Container(
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: color_grey)),
      ),
      child: Container(
        height: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: select ? color_black : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: (!outside && today) ? color_black : pWhite),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: custom(
                    17,
                    FontWeight.w600,
                    outside
                        ? color_grey
                        : today
                        ? pWhite
                        : saturday
                        ? color_blue
                        : sunday
                        ? color_red
                        : color_black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 3),
                child: Column(
                  children: [
                    for (var i in multiSchedule.entries)
                      Container(
                        width: double.infinity,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Color(i.value['model'].colorCode),
                          borderRadius: i.value['type'].contains('start')
                              ? BorderRadius.horizontal(left: Radius.circular(8))
                              : i.value['type'].contains('end')
                              ? BorderRadius.horizontal(right: Radius.circular(8))
                              : null,
                        ),
                        child: Center(
                          child: i.value['type'].contains('middle') ? Text(i.value['model'].title, style: white(14, FontWeight.w500)) : null,
                        ),
                      ),
                    for (var i in singleSchedule.entries)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(width: 3, color: Color(i.value['model'].colorCode))),
                        ),
                        child: Text(i.value['model'].title, style: custom(14, FontWeight.w500, color_black, null, null, 1)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// 오늘 : 원형 / pwhite 배경 / secondary 테두리
// 선택된 단일 날짜 : 원형 // primary 배경 / 테두리 pwhite
// 선택된 범위 내 날짜 : 사각형 // primary 배경 / 테두리 pwhite
// 시작 날짜 : 왼쪽 둥근 사각형 // primary 배경 / 테두리 pwhite
// 끝 날짜 : 오른쪽 둥근 사각형 // primary 배경 / 테두리 pwhite
Widget calendarDaySelectBuild(DateTime day, String startDate, String endDate, bool outside) {
  // 문자열 변환 없이 직접 비교 (DateTime을 비교할 때 훨씬 빠름)
  final dayDate = DateTime(day.year, day.month, day.day);
  final start = DateTime.parse(startDate);
  final end = DateTime.parse(endDate);
  final now = DateTime.now();
  final currentNow = DateTime(now.year, now.month, now.day);

  // 범위 계산 (매 빌드마다 리스트 생성 제거)
  bool inRange = !dayDate.isBefore(start) && !dayDate.isAfter(end);
  bool isStart = dayDate == start && start != end;
  bool isEnd = dayDate == end && start != end;
  bool isToday = dayDate == currentNow;

  // 색상과 모양 지정
  final Color bgColor = (isToday && !inRange) || !inRange ? pWhite : primary;
  final Color borderColor = isToday && !inRange
      ? secondary
      : inRange
      ? primary
      : pWhite;

  final BorderRadius? radius = isStart
      ? const BorderRadius.horizontal(left: Radius.circular(30))
      : isEnd
      ? const BorderRadius.horizontal(right: Radius.circular(30))
      : null;

  Color fontColor = outside ? color_grey : color_black;

  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: radius,
      shape: (isToday && !inRange || (start == end && dayDate == start)) ? BoxShape.circle : BoxShape.rectangle,
      border: Border.all(width: 2, color: borderColor),
    ),
    alignment: Alignment.center,
    child: Text('${day.day}', style: custom(18, FontWeight.w600, fontColor)),
  );
}
