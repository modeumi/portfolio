import 'dart:math';

import 'package:flutter_riverpod/legacy.dart';
import 'package:portfolio/models/profile_model.dart';
import 'package:utility/import_package.dart';

class ProfileState {
  final List<ProfileModel> profileList;
  final ProfileModel profile; // 작성/수정 중인 프로필
  final Set<String> checked; // 복사 대상으로 체크된 프로필 id
  final String selectedId; // mobile view에 연결되는 '사용 중' 프로필 id

  ProfileState({List<ProfileModel>? profileList, ProfileModel? profile, Set<String>? checked, this.selectedId = ''})
    : profileList = profileList ?? [],
      profile = profile ?? ProfileModel(),
      checked = checked ?? {};

  ProfileState copyWith({List<ProfileModel>? profileList, ProfileModel? profile, Set<String>? checked, String? selectedId}) {
    return ProfileState(
      profileList: profileList ?? this.profileList,
      profile: profile ?? this.profile,
      checked: checked ?? this.checked,
      selectedId: selectedId ?? this.selectedId,
    );
  }
}

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(ProfileState());

  final store = FirebaseFirestore.instance;

  // 등록된 프로필 목록 + 현재 사용 중 프로필 id 로드
  Future<void> getProfiles() async {
    final snapshot = await store.collection('Profiles').get();
    final List<ProfileModel> list = snapshot.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return ProfileModel.fromMap(data);
    }).toList();

    final config = await store.collection('Config').doc('profile').get();
    final String selectedId = (config.data()?['selectedId'] as String?) ?? '';

    state = state.copyWith(profileList: list, selectedId: selectedId);
  }

  void setProfile(ProfileModel model) {
    state = state.copyWith(profile: model);
  }

  // 추가(새 프로필) 진입
  void newProfile() {
    state = ProfileState(profileList: state.profileList, profile: ProfileModel(), checked: state.checked, selectedId: state.selectedId);
  }

  void changeProfileField(String key, String value) {
    ProfileModel p = state.profile;
    if (key == 'name') {
      p = p.copyWith(name: value);
    } else if (key == 'content') {
      p = p.copyWith(content: value);
    }
    state = state.copyWith(profile: p);
  }

  // 작성한 프로필 저장 (Firestore + 메모리)
  Future<void> saveProfile() async {
    final List<ProfileModel> list = [...state.profileList];
    ProfileModel p = state.profile;
    if (p.id == null || p.id!.isEmpty) {
      p = p.copyWith(id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}');
      list.add(p);
    } else {
      final idx = list.indexWhere((e) => e.id == p.id);
      if (idx >= 0) {
        list[idx] = p;
      } else {
        list.add(p);
      }
    }
    state = state.copyWith(profileList: list, profile: p);
    await store.collection('Profiles').doc(p.id).set(p.toMap(), SetOptions(merge: true));
  }

  // 복사 체크 토글
  void toggleCheck(String id) {
    final Set<String> set = {...state.checked};
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    state = state.copyWith(checked: set);
  }

  // 체크된 프로필 복사 (사본 생성)
  Future<void> copyChecked() async {
    for (final id in state.checked) {
      final src = state.profileList.where((p) => p.id == id).toList();
      if (src.isEmpty) continue;
      final newId = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';
      final copy = src.first.copyWith(id: newId, name: '${src.first.name ?? '프로필'} 복사');
      await store.collection('Profiles').doc(newId).set(copy.toMap(), SetOptions(merge: true));
    }
    state = state.copyWith(checked: {});
    await getProfiles();
  }

  // 사용할 프로필 선택 (mobile view 연결 대상)
  Future<void> selectProfile(String id) async {
    state = state.copyWith(selectedId: id);
    await store.collection('Config').doc('profile').set({'selectedId': id}, SetOptions(merge: true));
  }

  // mobile view용: 현재 선택된 프로필 1건 로드
  Future<ProfileModel?> loadSelected() async {
    final config = await store.collection('Config').doc('profile').get();
    final String? selectedId = config.data()?['selectedId'] as String?;
    if (selectedId == null || selectedId.isEmpty) return null;
    final doc = await store.collection('Profiles').doc(selectedId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return ProfileModel.fromMap(data);
  }
}

final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController();
});
