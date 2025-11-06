// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CalendarModel {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? todo;
  CalendarModel({this.startDate, this.endDate, this.todo});

  CalendarModel copyWith({DateTime? startDate, DateTime? endDate, String? todo}) {
    return CalendarModel(startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate, todo: todo ?? this.todo);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'startDate': startDate?.millisecondsSinceEpoch, 'endDate': endDate?.millisecondsSinceEpoch, 'todo': todo};
  }

  factory CalendarModel.fromMap(Map<String, dynamic> map) {
    return CalendarModel(
      startDate: map['startDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int) : null,
      endDate: map['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int) : null,
      todo: map['todo'] != null ? map['todo'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CalendarModel.fromJson(String source) => CalendarModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CalendarModel(startDate: $startDate, endDate: $endDate, todo: $todo)';

  @override
  bool operator ==(covariant CalendarModel other) {
    if (identical(this, other)) return true;

    return other.startDate == startDate && other.endDate == endDate && other.todo == todo;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode ^ todo.hashCode;
}
