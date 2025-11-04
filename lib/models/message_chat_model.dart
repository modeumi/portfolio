// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MessageChatModel {
  String? user;
  String? message;
  String? createAt;
  MessageChatModel({this.user, this.message, this.createAt});

  MessageChatModel copyWith({String? user, String? message, String? createAt}) {
    return MessageChatModel(user: user ?? this.user, message: message ?? this.message, createAt: createAt ?? this.createAt);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'user': user, 'message': message, 'createAt': createAt};
  }

  factory MessageChatModel.fromMap(Map<String, dynamic> map) {
    return MessageChatModel(
      user: map['user'] != null ? map['user'] as String : null,
      message: map['message'] != null ? map['message'] as String : null,
      createAt: map['createAt'] != null ? map['createAt'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageChatModel.fromJson(String source) => MessageChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'MessageChatModel(user: $user, message: $message, createAt: $createAt)';

  @override
  bool operator ==(covariant MessageChatModel other) {
    if (identical(this, other)) return true;

    return other.user == user && other.message == message && other.createAt == createAt;
  }

  @override
  int get hashCode => user.hashCode ^ message.hashCode ^ createAt.hashCode;
}
