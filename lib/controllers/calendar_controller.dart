// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/legacy.dart';
import 'package:portfolio/models/calendar_model.dart';

class CalendarState {
  final DateTime targetDate;
  final Map<String, List<CalendarModel>> schedule;
  final String paletteColor;

  final List<String> paletteColorList = ['7986CC', 'D44245', 'F27198', 'EB9E5A', 'FCCB05', '5FC59D', '69B054'];
  CalendarState({DateTime? targetDate, Map<String, List<CalendarModel>>? schedule, this.paletteColor = ''})
    : targetDate = targetDate ?? DateTime.now(),
      schedule = schedule ?? {};

  CalendarState copyWith({DateTime? targetDate, Map<String, List<CalendarModel>>? schedule, String? paletteColor}) {
    return CalendarState(
      targetDate: targetDate ?? this.targetDate,
      schedule: schedule ?? this.schedule,
      paletteColor: paletteColor ?? this.paletteColor,
    );
  }
}

class CalendarController extends StateNotifier<CalendarState> {
  CalendarController() : super(CalendarState());

  void changeCalendarDate(DateTime date) {
    state = state.copyWith(targetDate: date);
  }

  void changePaletteColor(String colorCode) {
    state = state.copyWith(paletteColor: colorCode);
  }
}

final calendarControllerProvider = StateNotifierProvider<CalendarController, CalendarState>((ref) {
  return CalendarController();
});
