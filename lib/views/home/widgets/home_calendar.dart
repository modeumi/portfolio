import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/views/calendar/widgets/calendar_view.dart';
import 'package:utility/textstyle.dart';

class HomeCalendar extends ConsumerStatefulWidget {
  const HomeCalendar({super.key});

  @override
  ConsumerState<HomeCalendar> createState() => _HomeCalendarState();
}

class _HomeCalendarState extends ConsumerState<HomeCalendar> with RiverpodMixin {
  DateTime firstDate = DateTime(2020, 1, 0);
  DateTime lastDate = DateTime(2030, 12, 31);

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
                GestureDetector(
                  onTap: () {
                    calendarController.changeEdit(false);
                    calendarController.initAddSchedule();
                    context.push('/calendar_add_schedule', extra: 'home');
                  },
                  child: Icon(Icons.add, size: 30),
                ),
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
          CalendarView(
            emptyScheduleAction: () {
              calendarController.changeEdit(false);
              calendarController.initAddSchedule();
              context.push('/calendar_add_schedule', extra: 'home');
            },
            existScheduleAction: () {
              context.push('/calendar', extra: 'homeCalendar');
            },
            showScheduleLimit: true,
          ),
        ],
      ),
    );
  }
}
