import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import 'package:portfolio/models/schedules_model.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';

class CalendarState {
  final ScheduleModel schedule;

  final DateTime targetDate;
  final DateTime lunarDate;

  final bool edit;

  final Map<String, dynamic> schedules;

  final Map<String, dynamic> searchSchedule;

  final List<ScheduleModel> dailySchedules;
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
  CalendarState({
    this.edit = false,
    DateTime? targetDate,
    DateTime? lunarDate,
    ScheduleModel? schedule,
    Map<String, dynamic>? schedules,
    Map<String, dynamic>? searchSchedule,
    List<String>? holiday,
    List<ScheduleModel>? dailySchedules,
  }) : targetDate = targetDate ?? DateTime.now(),
       lunarDate = lunarDate ?? DateTime.now(),
       schedule = schedule ?? ScheduleModel(),
       schedules = schedules ?? {},
       searchSchedule = searchSchedule ?? {},
       holiday = holiday ?? [],
       dailySchedules = dailySchedules ?? [];

  CalendarState copyWith({
    DateTime? targetDate,
    DateTime? lunarDate,
    ScheduleModel? schedule,
    Map<String, dynamic>? schedules,
    Map<String, dynamic>? searchSchedule,
    List<String>? holiday,
    bool? edit,
    List<ScheduleModel>? dailySchedules,
  }) {
    return CalendarState(
      targetDate: targetDate ?? this.targetDate,
      lunarDate: lunarDate ?? this.lunarDate,
      schedule: schedule ?? this.schedule,
      edit: edit ?? this.edit,
      schedules: schedules ?? this.schedules,
      searchSchedule: searchSchedule ?? this.searchSchedule,
      holiday: holiday ?? this.holiday,
      dailySchedules: dailySchedules ?? this.dailySchedules,
    );
  }
}

class CalendarController extends StateNotifier<CalendarState> {
  CalendarController() : super(CalendarState());

  final store = FirebaseFirestore.instance;

  Future<void> changeCalendarDate(DateTime date) async {
    DateTime beforeDate = state.targetDate;
    state = state.copyWith(targetDate: date);
    await getSolarDate();
    if (state.targetDate.month != beforeDate.month) {
      await getHoliday();
    }
  }

  void changeEdit(bool type) {
    state = state.copyWith(edit: type);
  }

  void initAddSchedule() {
    ScheduleModel schedule = ScheduleModel();
    DateTime day = state.targetDate;
    DateTime startDate = DateTime(day.year, day.month, day.day, 8, 0, 0);
    DateTime endDate = DateTime(day.year, day.month, day.day, 9, 0, 0);
    int colorCode = 0xFF7986CC;
    schedule = schedule.copyWith(
      startDate: date_to_string_yyyyMMdd('-', startDate),
      endDate: date_to_string_yyyyMMdd('-', endDate),
      startTime: time_to_string('hms', startDate),
      endTime: time_to_string('hms', endDate),
      allDay: false,
      colorCode: colorCode,
    );
    state = state.copyWith(schedule: schedule);
  }

  void scheduleModelUpdate(String type, dynamic value) {
    ScheduleModel model = state.schedule;
    if (type == 'allDay') {
      if (value == true) {
        model = model.copyWith(startTime: '00:00:00', endTime: '00:00:00', allDay: true);
      } else {
        model = model.copyWith(startTime: '08:00:00', endTime: '09:00:00', allDay: false);
      }
    } else if (type == 'color') {
      model = model.copyWith(colorCode: value);
    } else if (type == 'start') {
      String strDate = date_to_string_yyyyMMdd('-', value);
      model = model.copyWith(startDate: strDate);
      if (value.isAfter(DateTime.parse(state.schedule.endDate!))) {
        model = model.copyWith(endDate: strDate);
      }
    } else if (type == 'end') {
      String strDate = date_to_string_yyyyMMdd('-', value);
      model = model.copyWith(endDate: strDate);
      if (value.isBefore(DateTime.parse(state.schedule.startDate!))) {
        model = model.copyWith(startDate: strDate);
      }
    }
    state = state.copyWith(schedule: model);
  }

  // type => true = start, false = end
  bool scheduleDateUpdate(DateTime date, bool type) {
    ScheduleModel model = state.schedule;
    bool result = false;
    DateTime startDate = DateTime.parse(state.schedule.startDate!);
    DateTime endDate = DateTime.parse(state.schedule.endDate!);

    if ((date.isAfter(endDate) && type) || (date.isBefore(startDate) && !type)) {
      model = model.copyWith(
        startDate: date_to_string_yyyyMMdd('-', date),
        endDate: date_to_string_yyyyMMdd('-', date),
        startTime: model.startTime,
        endTime: model.endTime,
        // startDate: DateTime(date.year, date.month, date.day, model.startDate!.hour, model.startDate!.minute, 0),
        // endDate: DateTime(date.year, date.month, date.day, model.endDate!.hour, model.endDate!.minute, 0),
      );
      result = false;
    } else if (type) {
      model = model.copyWith(startDate: date_to_string_yyyyMMdd('-', date), startTime: model.startTime);
      result = false;
    } else {
      model = model.copyWith(endDate: date_to_string_yyyyMMdd('-', date), endTime: model.endTime);
      result = true;
    }
    state = state.copyWith(schedule: model);
    return result;
  }

  void scheduleTimeUpdate(String type, String field, String value) {
    String modelTime = type == 'start' ? state.schedule.startTime! : state.schedule.endTime!;
    List<String> times = modelTime.split(':');
    bool isPm = int.parse(times.first) >= 12;
    value = value.padLeft(2, '0');
    // DateTime newTime = modelDate;
    // String beforeTime = reforme_time_short('mkor', time_to_string('hms', modelDate));
    if (value == '오후' && int.parse(times.first) < 12) {
      int modelHour = int.parse(times.first);
      modelTime = '${modelHour + 12}:${times[1]}:00';
    } else if (value == '오전' && int.parse(times.first) >= 12) {
      int modelHour = int.parse(times.first) - 12;
      modelTime = '${modelHour.toString().padLeft(2, '0')}:${times[1]}:00';
    } else if (field == 'hour') {
      modelTime = '${(int.parse(value) + (isPm ? 12 : 0)).toString().padLeft(2, '0')}:${times[1]}:00';
    } else if (field == 'minute') {
      modelTime = '${times[0]}:$value:00';
    }

    ScheduleModel model = state.schedule;
    if (type == 'start') {
      DateTime start = DateTime.parse('${model.startDate} $modelTime');
      DateTime end = DateTime.parse('${model.endDate} ${model.endTime}');
      if (start.isAfter(end)) {
        model = model.copyWith(endTime: modelTime);
      }
      model = model.copyWith(startTime: modelTime);
    } else {
      DateTime start = DateTime.parse('${model.startDate} ${model.startTime}');
      DateTime end = DateTime.parse('${model.endDate} $modelTime');
      if (end.isBefore(start)) {
        model = model.copyWith(startTime: modelTime);
      }
      model = model.copyWith(endTime: modelTime);
    }
    state = state.copyWith(schedule: model);
  }

  Future<bool> addSchedule(Map<String, dynamic> data) async {
    Map<String, dynamic> scheduleData = state.schedule.toMap();
    scheduleData.addAll(data);

    DateTime startDate = DateTime.parse(scheduleData['startDate']);
    DateTime endDate = DateTime.parse(scheduleData['endDate']);

    List<String> dateKey = [];
    while (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
      String strStart = date_to_string_yyyyMMdd('-', startDate);
      dateKey.add(strStart);
      startDate = startDate.add(Duration(days: 1));
    }

    DateTime now = DateTime.now();
    int scheduleId = now.millisecondsSinceEpoch;
    scheduleData['date'] = dateKey;
    scheduleData['scheduleId'] = scheduleId;
    Map<String, dynamic> uploadData = {'$scheduleId': scheduleData};
    try {
      for (var i in dateKey) {
        await store.collection('Schedule').doc(i).set(uploadData, SetOptions(merge: true));
      }
      await loadSchedule();
      await loadDailySchedule();
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
    Map<String, dynamic> result = {};
    for (var i in schedules.docs) {
      for (var element in i.data().entries) {
        String id = element.value['scheduleId'].toString();
        dataProcess[id] = element.value;
        dataProcess[id]['id'] = element.key;
      }
    }

    for (var i in dataProcess.entries) {
      Map<String, dynamic> model = dataProcess[i.key];
      model['date'] = List<String>.from(i.value['date']);
      dataProcess[i.key] = ScheduleModel.fromMap(model);
      result[i.key] = dataProcess[i.key];
    }

    // result print : {1763339250119: ScheduleModel(date: [2025-11-01, 2025-11-02, 2025-11-03], startTime: 00:00, endTime: 18:30, allDay: false, title: ex1, note: asdasd, colorCode: 4286154444)}
    state = state.copyWith(schedules: result);
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
          'solMonth': state.targetDate.month.toString().padLeft(2, '0'),
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

  Future<void> getSolarDate() async {
    String serviceKey = dotenv.env['ServiceKey'] ?? '';
    if (serviceKey != '') {
      final uri = Uri(
        scheme: 'http',
        host: 'apis.data.go.kr',
        path: '/B090041/openapi/service/LrsrCldInfoService/getLunCalInfo',
        queryParameters: {
          'solYear': state.targetDate.year.toString(),
          'solMonth': state.targetDate.month.toString().padLeft(2, '0'),
          'solDay': state.targetDate.day.toString().padLeft(2, '0'),
          'serviceKey': serviceKey,
          '_type': 'json',
        },
      );
      try {
        final response = await get(uri);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final body = data['response']['body'];
          final item = body['items']['item'];
          String lunDate = '${item['lunYear']}-${item['lunMonth']}-${item['lunDay']}';
          state = state.copyWith(lunarDate: DateTime.parse(lunDate));
        }
      } catch (e) {
        print('요청실패 : $e');
      }
    }
  }

  Future<void> loadDailySchedule() async {
    String strDate = date_to_string_yyyyMMdd('-', state.targetDate);
    final snapshot = await store.collection('Schedule').doc(strDate).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    final sortData = data.entries.toList()..sort((a, b) => b.value['date'].length.compareTo(a.value['date'].length));
    data = Map.fromEntries(sortData);

    List<ScheduleModel> result = [];
    for (var i in data.entries) {
      Map<String, dynamic> modelMap = i.value;
      modelMap['date'] = List<String>.from(modelMap['date']);
      modelMap['id'] = i.key;
      ScheduleModel model = ScheduleModel.fromMap(i.value);
      result.add(model);
    }

    state = state.copyWith(dailySchedules: result);
  }

  void setSchedule(ScheduleModel model) {
    state = state.copyWith(schedule: model);
  }

  Future<void> deleteSchedule() async {
    final schedules = await store
        .collection('Schedule')
        .orderBy(FieldPath.documentId)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: state.schedule.startDate)
        .where(FieldPath.documentId, isLessThanOrEqualTo: state.schedule.endDate)
        .get();

    final batch = store.batch();

    for (var i in schedules.docs) {
      batch.update(i.reference, {state.schedule.id!: FieldValue.delete()});
    }
    try {
      await batch.commit();
      await loadSchedule();
      await loadDailySchedule();
      Map<String, dynamic> search = state.searchSchedule;
      for (var i in search.entries) {
        for (var model in i.value) {
          if (model.id == state.schedule.id) {
            search[i.key].remove(model);
          }
        }
      }
      state = state.copyWith(searchSchedule: search);
    } catch (e) {
      print('커밋 에러 $e');
    }
  }

  Future<void> searchSchedule(String type, dynamic search) async {
    DateTime now = DateTime.now();
    DateTime searchStart = DateTime(now.year - 2, now.month, now.day);
    DateTime searchEnd = DateTime(now.year + 2, now.month, now.day);
    String strStart = date_to_string_yyyyMMdd('-', searchStart);
    String strEnd = date_to_string_yyyyMMdd('-', searchEnd);
    final schedules = await store
        .collection('Schedule')
        .orderBy(FieldPath.documentId)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: strStart)
        .where(FieldPath.documentId, isLessThanOrEqualTo: strEnd)
        .get();
    Map<String, List<ScheduleModel>> result = {};

    for (var doc in schedules.docs) {
      for (var data in doc.data().entries) {
        if ((type == 'color' && data.value['colorCode'] == int.parse(search)) ||
            (type == 'text' && (data.value['title'].contains(search) || data.value['note'].contains(search)))) {
          if (!result.containsKey(doc.id)) {
            result[doc.id] = [];
          }
          Map<String, dynamic> modelMap = data.value;
          modelMap['id'] = data.key;
          modelMap['date'] = List<String>.from(data.value['date']);
          ScheduleModel model = ScheduleModel.fromMap(modelMap);
          result[doc.id]!.add(model);
        }
      }
    }
    state = state.copyWith(searchSchedule: result);
  }

  void clearSearchResult() {
    state = state.copyWith(searchSchedule: {});
  }
}

final calendarControllerProvider = StateNotifierProvider<CalendarController, CalendarState>((ref) {
  return CalendarController();
});
