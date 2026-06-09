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
      ProjectModel(id: 'ERP', name: '모빌리티 ERP', icon: 'images/ERP.svg', content: ''),
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
