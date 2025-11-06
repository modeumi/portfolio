import 'package:flutter/material.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:utility/color.dart';
import 'package:utility/format.dart';
import 'package:utility/textstyle.dart';

Widget CalendarBuildContainer(bool outside, DateTime focusedDay, DateTime day) {
  DateTime now = DateTime.now();
  String strFocusedDay = date_to_string_yyyyMMdd('-', focusedDay);
  String strDay = date_to_string_yyyyMMdd('-', day);
  String strToday = date_to_string_yyyyMMdd('-', now);
  bool select = strDay == strFocusedDay;
  bool saturday = day.weekday == DateTime.saturday;
  bool sunday = day.weekday == DateTime.sunday;
  bool today = strToday == strDay;
  return FractionallySizedBox(
    widthFactor: 1,
    heightFactor: 1,
    child: Container(
      height: double.infinity,
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 0.5, color: color_grey)),
      ),
      child: Container(
        height: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 1.5),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: select ? color_black : pWhite),
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
              child: SizedBox(width: double.infinity, height: double.infinity),
            ),
          ],
        ),
      ),
    ),
  );
}
