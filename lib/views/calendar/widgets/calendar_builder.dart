import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:utility/color.dart';
import 'package:utility/textstyle.dart';

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
