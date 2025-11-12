import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';

import 'package:portfolio/models/calendar_model.dart';
import 'package:utility/crypto.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';

class CalendarState {
  final DateTime targetDate;
  final CalendarModel schedule;
  final Map<String, dynamic> schedules;

  final List<int> paletteColorList = [
    0xFF7986CC,
    0xFFD44245,
    0xFFF27198,
    0xFFEB9E5A,
    0xFFFCCB05,
    0xFF5FC59D,
    0xFF69B054,
    0xFF63D1D2,
    0xFF81AAE8,
    0xFF4D7ADF,
    0xFFB093E7,
    0xFFA9A9A9,
  ];
  CalendarState({DateTime? targetDate, CalendarModel? schedule, Map<String, dynamic>? schedules, int? paletteColor})
    : targetDate = targetDate ?? DateTime.now(),
      schedule = schedule ?? CalendarModel(),
      schedules = schedules ?? {};

  CalendarState copyWith({DateTime? targetDate, CalendarModel? schedule, Map<String, dynamic>? schedules}) {
    return CalendarState(targetDate: targetDate ?? this.targetDate, schedule: schedule ?? this.schedule, schedules: schedules ?? this.schedules);
  }
}

class CalendarController extends StateNotifier<CalendarState> {
  CalendarController() : super(CalendarState());

  final store = FirebaseFirestore.instance;

  void changeCalendarDate(DateTime date) {
    state = state.copyWith(targetDate: date);
  }

  void initAddSchedule() {
    CalendarModel schedule = CalendarModel();
    DateTime day = state.targetDate;
    DateTime startDate = DateTime(day.year, day.month, day.day, 8, 0, 0);
    DateTime endDate = DateTime(day.year, day.month, day.day, 9, 0, 0);
    int colorCode = 0xFF7986CC;
    schedule = schedule.copyWith(startDate: startDate, endDate: endDate, allDay: false, colorCode: colorCode);
    state = state.copyWith(schedule: schedule);
  }

  void scheduleModelUpdate(String type, dynamic value) {
    CalendarModel model = state.schedule;
    if (type == 'allDay') {
      if (value == true) {
        model = model.copyWith(startDate: DateTime(model.startDate!.year, model.startDate!.month, model.startDate!.day, 0, 0, 0));
        model = model.copyWith(endDate: DateTime(model.endDate!.year, model.endDate!.month, model.endDate!.day, 23, 59, 0));
      } else {
        model = model.copyWith(startDate: DateTime(model.startDate!.year, model.startDate!.month, model.startDate!.day, 8, 0, 0));
        model = model.copyWith(endDate: DateTime(model.endDate!.year, model.endDate!.month, model.endDate!.day, 9, 0, 0));
      }
      model = model.copyWith(allDay: value);
    } else if (type == 'color') {
      model = model.copyWith(colorCode: value);
    } else if (type == 'start') {
      model = model.copyWith(startDate: value);
      if (value.isAfter(state.schedule.endDate!)) {
        model = model.copyWith(endDate: value);
      }
    } else if (type == 'end') {
      model = model.copyWith(endDate: value);
      if (value.isBefore(state.schedule.startDate!)) {
        model = model.copyWith(startDate: value);
      }
    }
    state = state.copyWith(schedule: model);
  }

  // type => true = start, false = end
  bool scheduleDateUpdate(DateTime date, bool type) {
    CalendarModel model = state.schedule;
    bool result = false;
    if ((date.isAfter(state.schedule.endDate!) && type) || (date.isBefore(state.schedule.startDate!) && !type)) {
      model = model.copyWith(
        startDate: DateTime(date.year, date.month, date.day, model.startDate!.hour, model.startDate!.minute, 0),
        endDate: DateTime(date.year, date.month, date.day, model.endDate!.hour, model.endDate!.minute, 0),
      );
      result = false;
    } else if (type) {
      model = model.copyWith(
        startDate: DateTime(date.year, date.month, date.day, model.startDate!.hour, model.startDate!.minute, 0),
        endDate: DateTime(date.year, date.month, date.day, model.endDate!.hour, model.endDate!.minute, 0),
      );
      result = false;
    } else {
      model = model.copyWith(endDate: DateTime(date.year, date.month, date.day, model.endDate!.hour, model.endDate!.minute, 0));
      result = true;
    }
    state = state.copyWith(schedule: model);
    return result;
  }

  void scheduleTimeUpdate(String type, String field, dynamic value) {
    DateTime modelDate = type == 'start' ? state.schedule.startDate! : state.schedule.endDate!;
    DateTime newTime = modelDate;
    String beforeTime = reforme_time_short('mkor', time_to_string('hms', modelDate));
    if (field == 'ampm') {
      if (value == beforeTime.split(' ').first) {
        return;
      } else {
        newTime = DateTime(modelDate.year, modelDate.month, modelDate.day, modelDate.hour + (value == '오후' ? 12 : -12), modelDate.minute, 0);
      }
    } else if (field == 'hour') {
      bool isAm = beforeTime.split(' ').first == '오전';
      int hour;
      if (value == 12) {
        hour = isAm ? 0 : 12;
      } else {
        hour = value + (isAm ? 0 : 12);
      }
      newTime = DateTime(modelDate.year, modelDate.month, modelDate.day, hour, modelDate.minute, 0);
    } else if (field == 'minute') {
      newTime = DateTime(modelDate.year, modelDate.month, modelDate.day, modelDate.hour, value, 0);
    }
    scheduleModelUpdate(type, newTime);
  }

  Future<bool> addSchedule(Map<String, dynamic> data) async {
    Map<String, dynamic> scheduleData = state.schedule.toMap();
    String docId = date_to_string_yyMM('-', state.schedule.startDate);

    scheduleData.addAll(data);
    DateTime now = DateTime.now();
    Map<String, dynamic> uploadData = {'${date_to_string_yyyyMMdd('-', now)} ${time_to_string('hmss', now)}': scheduleData};
    try {
      await store.collection('Schedule').doc(docId).set(uploadData, SetOptions(merge: true));
      await loadSchedule();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadSchedule() async {
    String docId = date_to_string_yyMM('-', state.targetDate);
    DocumentSnapshot schedules = await store.collection('Schedule').doc(docId).get();
    if (schedules.data() != null) {
      Map<String, dynamic> result = schedules.data() as Map<String, dynamic>;
      Map<String, dynamic> scheduleData = {};
      int itemKey = 1;
      for (var i in result.entries) {
        DateTime start = DateTime.fromMillisecondsSinceEpoch(i.value['startDate']);
        DateTime end = DateTime.fromMillisecondsSinceEpoch(i.value['endDate']);
        String strStart = date_to_string_yyyyMMdd('-', start);
        String strEnd = date_to_string_yyyyMMdd('-', end);
        CalendarModel model = CalendarModel.fromMap(i.value);
        // 하루짜리 일정일 경우 single 태그로 저장
        if (strStart == strEnd) {
          scheduleData[strStart] = {'model': model, 'type': 'single_$itemKey'};
        } else {
          // 기간내 하루씩 추가하여 list에 저장
          List<String> scheduleDays = [];
          while (start.isBefore(end)) {
            String strRangeStart = date_to_string_yyyyMMdd('-', start);
            scheduleDays.add(strRangeStart);
            start = start.add(Duration(days: 1));
          }
          for (var i in scheduleDays) {
            if (scheduleDays.first == i) {
              scheduleData[i] = {'model': model, 'type': 'start_$itemKey'};
            } else if (scheduleDays.last == i) {
              scheduleData[i] = {'model': model, 'type': 'end_$itemKey'};
            } else {
              scheduleData[i] = {'model': model, 'type': 'middle_$itemKey'};
            }
          }
        }
        itemKey++;
      }

      state = state.copyWith(schedules: scheduleData);
    }
  }

  Future<List<String>> getHoliday() async {
    List<String> holiday = [];
    String serviceKey = dotenv.env['ServiceKey'] ?? '';
    if (serviceKey != '') {
      final uri = Uri.https(
        'https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService',
      ).replace(queryParameters: {'serviceKey': serviceKey, 'solYear': state.targetDate.year, 'solMonth': state.targetDate.month, '_type': 'json'});
      print(uri);
      try {
        final response = await get(uri);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print(data);
        }
      } catch (e) {
        print('요청실패 $e');
      }
    }

    return holiday;
  }
}

final calendarControllerProvider = StateNotifierProvider<CalendarController, CalendarState>((ref) {
  return CalendarController();
});
