// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ProjectModel {
  final String? id;
  final String? name; // 프로젝트 이름
  final String? icon; // firebase storage 링크 (또는 임시 asset 경로)
  final String? content; // 특수 태그가 섞인 본문 내용
  final String? background; // 상세 페이지 배경 (firebase storage 링크 또는 #hex 색상)

  ProjectModel({this.id, this.name, this.icon, this.content, this.background});

  ProjectModel copyWith({String? id, String? name, String? icon, String? content, String? background}) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      content: content ?? this.content,
      background: background ?? this.background,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name, 'icon': icon, 'content': content, 'background': background};
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      icon: map['icon'] != null ? map['icon'] as String : null,
      content: map['content'] != null ? map['content'] as String : null,
      background: map['background'] != null ? map['background'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectModel.fromJson(String source) => ProjectModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ProjectModel(id: $id, name: $name, icon: $icon, content: $content, background: $background)';

  @override
  bool operator ==(covariant ProjectModel other) {
    if (identical(this, other)) return true;
    return other.id == id && other.name == name && other.icon == icon && other.content == content && other.background == background;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ icon.hashCode ^ content.hashCode ^ background.hashCode;
}
