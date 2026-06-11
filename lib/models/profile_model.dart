// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ProfileModel {
  final String? id;
  final String? name; // 프로필 이름/라벨
  final String? content; // 자기소개 HTML 본문

  ProfileModel({this.id, this.name, this.content});

  ProfileModel copyWith({String? id, String? name, String? content}) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name, 'content': content};
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      content: map['content'] != null ? map['content'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) => ProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ProfileModel(id: $id, name: $name, content: $content)';

  @override
  bool operator ==(covariant ProfileModel other) {
    if (identical(this, other)) return true;
    return other.id == id && other.name == name && other.content == content;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ content.hashCode;
}
