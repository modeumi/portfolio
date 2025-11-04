// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MessageTargetModel {
  String? name;
  String? lastContent;
  String? lastDate;
  String? password;
  bool? lock;
  MessageTargetModel({this.name, this.lastContent, this.lastDate, this.password, this.lock});

  MessageTargetModel copyWith({String? name, String? lastContent, String? lastDate, String? password, bool? lock}) {
    return MessageTargetModel(
      name: name ?? this.name,
      lastContent: lastContent ?? this.lastContent,
      lastDate: lastDate ?? this.lastDate,
      password: password ?? this.password,
      lock: lock ?? this.lock,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': name, 'lastContent': lastContent, 'lastDate': lastDate, 'password': password, 'lock': lock};
  }

  factory MessageTargetModel.fromMap(Map<String, dynamic> map) {
    return MessageTargetModel(
      name: map['name'] != null ? map['name'] as String : null,
      lastContent: map['lastContent'] != null ? map['lastContent'] as String : null,
      lastDate: map['lastDate'] != null ? map['lastDate'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      lock: map['lock'] != null ? map['lock'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageTargetModel.fromJson(String source) => MessageTargetModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MessageTargetModel(name: $name, lastContent: $lastContent, lastDate: $lastDate, password: $password, lock: $lock)';
  }

  @override
  bool operator ==(covariant MessageTargetModel other) {
    if (identical(this, other)) return true;

    return other.name == name && other.lastContent == lastContent && other.lastDate == lastDate && other.password == password && other.lock == lock;
  }

  @override
  int get hashCode {
    return name.hashCode ^ lastContent.hashCode ^ lastDate.hashCode ^ password.hashCode ^ lock.hashCode;
  }
}
