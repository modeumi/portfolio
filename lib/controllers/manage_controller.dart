import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:portfolio/models/project_model.dart';
import 'package:utility/import_package.dart' hide ImageSource;

// 업로드 전 로컬에 들고 있는 선택 이미지 (바이트 + mime)
class PickedImage {
  final Uint8List bytes;
  final String mime;
  PickedImage({required this.bytes, required this.mime});
}

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

  // 갤러리에서 이미지 선택 (업로드는 하지 않고 바이트만 반환)
  Future<PickedImage?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    final String mime = file.mimeType ?? 'image/png';
    if (!mime.startsWith('image/')) return null;
    final Uint8List bytes = await file.readAsBytes();
    return PickedImage(bytes: bytes, mime: mime);
  }

  // 선택해 둔 이미지를 firebase storage에 업로드하고 다운로드 URL 반환
  Future<String> uploadImage(PickedImage image, String folder) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';
    final ref = FirebaseStorage.instance.ref().child('$folder/$fileName');
    final upload = await ref.putData(image.bytes, SettableMetadata(contentType: image.mime));
    return upload.ref.getDownloadURL();
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
