// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class NoteModel {
  final String? id;
  final String? title;
  final String? content;
  final String? createAt;
  final String? updateAt;
  final String? cover;
  final int? pageColor;
  final bool? bookmark;
  NoteModel({this.id, this.title, this.content, this.createAt, this.updateAt, this.cover, this.pageColor, this.bookmark});

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? createAt,
    String? updateAt,
    String? cover,
    int? pageColor,
    bool? bookmark,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      cover: cover ?? this.cover,
      pageColor: pageColor ?? this.pageColor,
      bookmark: bookmark ?? this.bookmark,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'content': content,
      'createAt': createAt,
      'updateAt': updateAt,
      'cover': cover,
      'pageColor': pageColor,
      'bookmark': bookmark,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] != null ? map['id'] as String : null,
      title: map['title'] != null ? map['title'] as String : null,
      content: map['content'] != null ? map['content'] as String : null,
      createAt: map['createAt'] != null ? map['createAt'] as String : null,
      updateAt: map['updateAt'] != null ? map['updateAt'] as String : null,
      cover: map['cover'] != null ? map['cover'] as String : null,
      pageColor: map['pageColor'] != null ? map['pageColor'] as int : null,
      bookmark: map['bookmark'] != null ? map['bookmark'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory NoteModel.fromJson(String source) => NoteModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, content: $content, createAt: $createAt, updateAt: $updateAt, cover: $cover, pageColor: $pageColor, bookmark: $bookmark)';
  }

  @override
  bool operator ==(covariant NoteModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.content == content &&
        other.createAt == createAt &&
        other.updateAt == updateAt &&
        other.cover == cover &&
        other.pageColor == pageColor &&
        other.bookmark == bookmark;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        content.hashCode ^
        createAt.hashCode ^
        updateAt.hashCode ^
        cover.hashCode ^
        pageColor.hashCode ^
        bookmark.hashCode;
  }
}
