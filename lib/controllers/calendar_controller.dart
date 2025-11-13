import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';

import 'package:portfolio/models/calendar_model.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';

class CalendarState {
  final DateTime targetDate;
  final CalendarModel schedule;
  final List<Map<String, dynamic>> schedules;
  final List<String> holiday;

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
  CalendarState({DateTime? targetDate, CalendarModel? schedule, List<Map<String, dynamic>>? schedules, List<String>? holiday})
    : targetDate = targetDate ?? DateTime.now(),
      schedule = schedule ?? CalendarModel(),
      schedules = schedules ?? [],
      holiday = holiday ?? [];

  CalendarState copyWith({DateTime? targetDate, CalendarModel? schedule, List<Map<String, dynamic>>? schedules, List<String>? holiday}) {
    return CalendarState(
      targetDate: targetDate ?? this.targetDate,
      schedule: schedule ?? this.schedule,
      schedules: schedules ?? this.schedules,
      holiday: holiday ?? this.holiday,
    );
  }
}

class CalendarController extends StateNotifier<CalendarState> {
  CalendarController() : super(CalendarState());

  final store = FirebaseFirestore.instance;

  void changeCalendarDate(DateTime date) async {
    state = state.copyWith(targetDate: date);
    await getHoliday();
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
    scheduleData.addAll(data);

    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(scheduleData['startDate']);
    DateTime endDate = DateTime.fromMillisecondsSinceEpoch(scheduleData['endDate']);

    List<String> dateKey = [];
    while (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
      String strStart = date_to_string_yyyyMMdd('-', startDate);
      dateKey.add(strStart);
      startDate = startDate.add(Duration(days: 1));
    }

    DateTime now = DateTime.now();
    scheduleData.remove('startDate');
    scheduleData.remove('endDate');
    int scheduleId = now.millisecondsSinceEpoch;
    scheduleData['scheduleId'] = scheduleId;
    Map<String, dynamic> uploadData = {'$scheduleId': scheduleData};
    try {
      for (var i in dateKey) {
        await store.collection('Schedule').doc(i).set(uploadData, SetOptions(merge: true));
      }
      await loadSchedule();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadSchedule() async {
    DateTime targetDate = state.targetDate;
    DateTime rangeStart = DateTime(targetDate.year, targetDate.month, 1);
    DateTime rangeend = DateTime(targetDate.year, targetDate.month + 1, 0);
    String strRangeStart = date_to_string_yyyyMMdd('-', rangeStart);
    String strRangeEnd = date_to_string_yyyyMMdd('-', rangeend);

    final schedules = await store
        .collection('Schedule')
        .orderBy(FieldPath.documentId)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: strRangeStart)
        .where(FieldPath.documentId, isLessThanOrEqualTo: strRangeEnd)
        .get();

    Map<String, dynamic> dataProcess = {};
    for (var i in schedules.docs) {
      for (var element in i.data().entries) {
        String id = element.value['scheduleId'].toString();
        if (!dataProcess.containsKey(id)) {
          dataProcess[id] = {};
          dataProcess[id]['range'] = [];
          dataProcess[id]['model'] = element.value;
        }
        dataProcess[id]['range']!.add(i.id);
      }
    }
    print(dataProcess);

    // if (schedules.data() != null) {
    //   Map<String, dynamic> result = schedules.data() as Map<String, dynamic>;
    //   List<Map<String, dynamic>> schedule = [];
    //   for (var i in result.entries) {
    //     DateTime start = DateTime.fromMillisecondsSinceEpoch(i.value['startDate']);
    //     DateTime end = DateTime.fromMillisecondsSinceEpoch(i.value['endDate']);
    //     CalendarModel model = CalendarModel.fromMap(i.value);
    //     List<String> scheduleRange = [];
    //     while (start.isBefore(end)) {
    //       String strRangeStart = date_to_string_yyyyMMdd('-', start);
    //       scheduleRange.add(strRangeStart);
    //       start = start.add(Duration(days: 1));
    //     }
    //     Map<String, dynamic> scheduleData = {'date': scheduleRange, 'model': model};
    //     schedule.add(scheduleData);
    //   }

    //   schedule.sort((a, b) => (b['date'] as List).length.compareTo((a['date'] as List).length));

    //   state = state.copyWith(schedules: schedule);
    // }
  }

  Future<void> getHoliday() async {
    List<String> holiday = [];
    String serviceKey = dotenv.env['ServiceKey'] ?? '';
    if (serviceKey != '') {
      final uri = Uri(
        scheme: 'http',
        host: 'apis.data.go.kr',
        path: '/B090041/openapi/service/SpcdeInfoService/getRestDeInfo',
        queryParameters: {
          'serviceKey': serviceKey,
          'solYear': state.targetDate.year.toString(),
          'solMonth': state.targetDate.month.toString(),
          '_type': 'json',
        },
      );
      try {
        final response = await get(uri);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final body = data['response']['body'];
          final items = body['items'];
          if (items == '') {
            return;
          } else {
            final item = items['item'];
            if (body['totalCount'] <= 1) {
              DateTime date = DateTime.parse(item['locdate'].toString());
              String strDate = date_to_string_yyyyMMdd('-', date);
              holiday.add(strDate);
            } else {
              for (var i in item) {
                DateTime date = DateTime.parse(i['locdate'].toString());
                String strDate = date_to_string_yyyyMMdd('-', date);
                holiday.add(strDate);
              }
            }
          }
        }
        state = state.copyWith(holiday: holiday);
      } catch (e) {
        print('요청실패 $e');
      }
    }
  }

  Future<void> setDailySchedule(String day) async {
    List<String> fiveLengthSchedule = [];
    DateTime firstDate = DateTime.parse(day).add(Duration(days: -2));
    while (fiveLengthSchedule.length < 5) {
      String strDate = date_to_string_yyyyMMdd('-', firstDate);
      fiveLengthSchedule.add(strDate);
      firstDate = firstDate.add(Duration(days: 1));
    }
    print(fiveLengthSchedule);
    loadDailySchedule(fiveLengthSchedule.last);
    for (var i in fiveLengthSchedule) {}
  }

  Future<void> loadDailySchedule(String day) async {
    DateTime target = DateTime.parse(day);
    var targetMillis = target.millisecondsSinceEpoch;
    final snapshot = await FirebaseFirestore.instance.collection('Schedule').doc(date_to_string_yyMM('-', target)).get();
    print(day);
    print(snapshot.data());
  }
}

final calendarControllerProvider = StateNotifierProvider<CalendarController, CalendarState>((ref) {
  return CalendarController();
});
