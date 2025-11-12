// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CalendarModel {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? allDay;
  final String? title;
  final String? note;
  final int? colorCode;

  CalendarModel({this.startDate, this.endDate, this.allDay, this.title, this.note, this.colorCode});

  CalendarModel copyWith({DateTime? startDate, DateTime? endDate, bool? allDay, String? title, String? note, int? colorCode}) {
    return CalendarModel(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      allDay: allDay ?? this.allDay,
      title: title ?? this.title,
      note: note ?? this.note,
      colorCode: colorCode ?? this.colorCode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'allDay': allDay,
      'title': title,
      'note': note,
      'colorCode': colorCode,
    };
  }

  factory CalendarModel.fromMap(Map<String, dynamic> map) {
    return CalendarModel(
      startDate: map['startDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int) : null,
      endDate: map['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int) : null,
      allDay: map['allDay'] != null ? map['allDay'] as bool : null,
      title: map['title'] != null ? map['title'] as String : null,
      note: map['note'] != null ? map['note'] as String : null,
      colorCode: map['colorCode'] != null ? map['colorCode'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CalendarModel.fromJson(String source) => CalendarModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CalendarModel(startDate: $startDate, endDate: $endDate, allDay: $allDay, title: $title, note: $note, colorCode: $colorCode)';
  }

  @override
  bool operator ==(covariant CalendarModel other) {
    if (identical(this, other)) return true;

    return other.startDate == startDate &&
        other.endDate == endDate &&
        other.allDay == allDay &&
        other.title == title &&
        other.note == note &&
        other.colorCode == colorCode;
  }

  @override
  int get hashCode {
    return startDate.hashCode ^ endDate.hashCode ^ allDay.hashCode ^ title.hashCode ^ note.hashCode ^ colorCode.hashCode;
  }
}
