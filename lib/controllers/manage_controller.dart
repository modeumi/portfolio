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

  // 등록된 프로젝트 목록 가져오기
  // TODO: 아래 임시 데이터(folderData) 대신 Firestore 'Projects' 컬렉션에서 가져오도록 교체
  Future<void> getProjects() async {
    final List<ProjectModel> temp = [
      ProjectModel(
        id: 'ERP',
        name: '모빌리티 ERP',
        icon: 'images/ERP.svg',
        background: '#E3F3F9',
        content:
            '<size=22><b>버스 운수회사 통합 관리 시스템</b></size><br><br>'
            '배차 · 정산 · 근태를 <color=#4A90A4><b>한 곳에서</b></color> 관리합니다.<br><br>'
            '<size=15><color=#818181>* 본문은 특수 태그(size/color/b/img/br)로 꾸며집니다.</color></size>',
      ),
      ProjectModel(id: 'projectS', name: '프로젝트 S', icon: 'images/projectS.svg', content: ''),
      ProjectModel(id: 'sfac', name: '스팩스페이스', icon: 'images/sfac.svg', content: ''),
      ProjectModel(id: 'todayEat', name: '오늘뭐먹지?', icon: 'images/todayEat.svg', content: ''),
      ProjectModel(id: 'portfolio', name: '포트폴리오', icon: 'images/portfolio.svg', content: ''),
    ];
    state = state.copyWith(projectList: temp);

    // Firestore 연동 시:
    // final snapshot = await store.collection('Projects').get();
    // final list = snapshot.docs.map((d) => ProjectModel.fromMap({...d.data(), 'id': d.id})).toList();
    // state = state.copyWith(projectList: list);
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

  // 작성한 프로젝트 저장
  // TODO: Firestore 'Projects'에 영속화. 현재는 메모리 목록에만 반영
  void saveProject() {
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
  }
}

final manageControllerProvider = StateNotifierProvider<ManageController, ManageState>((ref) {
  return ManageController();
});
