import 'package:flutter_riverpod/legacy.dart';
import 'package:portfolio/models/project_model.dart';
import 'package:utility/import_package.dart';

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
}

final manageControllerProvider = StateNotifierProvider<ManageController, ManageState>((ref) {
  return ManageController();
});
