// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class ScheduleModel {
  final String? id;
  final List<String>? date;
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
  final bool? allDay;
  final String? title;
  final String? note;
  final int? colorCode;
  ScheduleModel({this.id, this.date, this.startDate, this.endDate, this.startTime, this.endTime, this.allDay, this.title, this.note, this.colorCode});

  ScheduleModel copyWith({
    String? id,
    List<String>? date,
    String? startDate,
    String? endDate,
    String? startTime,
    String? endTime,
    bool? allDay,
    String? title,
    String? note,
    int? colorCode,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      date: date ?? this.date,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      allDay: allDay ?? this.allDay,
      title: title ?? this.title,
      note: note ?? this.note,
      colorCode: colorCode ?? this.colorCode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'date': date,
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'allDay': allDay,
      'title': title,
      'note': note,
      'colorCode': colorCode,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] != null ? map['id'] as String : null,
      date: map['date'] != null ? List<String>.from((map['date'] as List<String>)) : null,
      startDate: map['startDate'] != null ? map['startDate'] as String : null,
      endDate: map['endDate'] != null ? map['endDate'] as String : null,
      startTime: map['startTime'] != null ? map['startTime'] as String : null,
      endTime: map['endTime'] != null ? map['endTime'] as String : null,
      allDay: map['allDay'] != null ? map['allDay'] as bool : null,
      title: map['title'] != null ? map['title'] as String : null,
      note: map['note'] != null ? map['note'] as String : null,
      colorCode: map['colorCode'] != null ? map['colorCode'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScheduleModel.fromJson(String source) => ScheduleModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ScheduleModel(id: $id, date: $date, startDate: $startDate, endDate: $endDate, startTime: $startTime, endTime: $endTime, allDay: $allDay, title: $title, note: $note, colorCode: $colorCode)';
  }

  @override
  bool operator ==(covariant ScheduleModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        listEquals(other.date, date) &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.allDay == allDay &&
        other.title == title &&
        other.note == note &&
        other.colorCode == colorCode;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        allDay.hashCode ^
        title.hashCode ^
        note.hashCode ^
        colorCode.hashCode;
  }
}
