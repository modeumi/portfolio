import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portfolio/models/project_model.dart';
import 'package:utility/import_package.dart' hide ImageSource;

class ManageState {
  final List<ProjectModel> projectList;
  final ProjectModel project; // 선택(이동/수정)된 프로젝트

  ManageState({List<ProjectModel>? projectList, ProjectModel? project}) : projectList = projectList ?? [], project = project ?? ProjectModel();

  ManageState copyWith({List<ProjectModel>? projectList, ProjectModel? project}) {
    return ManageState(projectList: projectList ?? this.projectList, project: project ?? this.project);
  }
}

class ManageController extends StateNotifier<ManageState> {
  ManageController() : super(ManageState());

  final store = FirebaseFirestore.instance;

  // Firestore 'Projects' 컬렉션에서 등록된 프로젝트 목록 가져오기
  Future<void> getProjects() async {
    final snapshot = await store.collection('Projects').get();
    final List<ProjectModel> list = snapshot.docs.map((d) {
      final data = d.data();
      data['id'] = d.id; // doc id를 모델 id로 사용
      return ProjectModel.fromMap(data);
    }).toList();
    state = state.copyWith(projectList: list);
  }

  void setProject(ProjectModel model) {
    state = state.copyWith(project: model);
  }

  // 추가(새 프로젝트) 진입 시 빈 프로젝트로 초기화
  void newProject() {
    state = ManageState(projectList: state.projectList, project: ProjectModel());
  }

  // 작성 중인 프로젝트 필드 갱신 (name / icon / content)
  void changeProjectField(String key, String value) {
    ProjectModel p = state.project;
    if (key == 'name') {
      p = p.copyWith(name: value);
    } else if (key == 'content') {
      p = p.copyWith(content: value);
    } else if (key == 'icon') {
      p = p.copyWith(icon: value);
    }
    state = state.copyWith(project: p);
  }

  // 갤러리에서 아이콘 선택 후 firebase storage 업로드 -> URL을 icon에 반영
  Future<void> pickProjectIcon() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      if (!(file.mimeType?.startsWith('image/') ?? false)) return;

      final bytes = await file.readAsBytes();
      final fileName = 'project_${DateTime.now().millisecondsSinceEpoch}';
      final ref = FirebaseStorage.instance.ref().child('project/$fileName');
      final upload = await ref.putData(bytes, SettableMetadata(contentType: file.mimeType));
      final url = await upload.ref.getDownloadURL();
      changeProjectField('icon', url);
    } catch (e) {
      debugPrint('아이콘 업로드 실패 : $e');
    }
  }

  // 작성한 프로젝트를 Firestore 'Projects'에 저장 (메모리 목록도 즉시 반영)
  Future<void> saveProject() async {
    final List<ProjectModel> list = [...state.projectList];
    ProjectModel p = state.project;
    if (p.id == null || p.id!.isEmpty) {
      p = p.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
      list.add(p);
    } else {
      final idx = list.indexWhere((e) => e.id == p.id);
      if (idx >= 0) {
        list[idx] = p;
      } else {
        list.add(p);
      }
    }
    state = ManageState(projectList: list, project: p);

    await store.collection('Projects').doc(p.id).set(p.toMap(), SetOptions(merge: true));
  }
}

final manageControllerProvider = StateNotifierProvider<ManageController, ManageState>((ref) {
  return ManageController();
});
