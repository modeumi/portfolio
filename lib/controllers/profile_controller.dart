import 'dart:math';

import 'package:flutter_riverpod/legacy.dart';
import 'package:portfolio/models/profile_model.dart';
import 'package:utility/import_package.dart';
import 'package:utility/toast_message.dart';

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
    try {
      final snapshot = await store.collection('Profiles').get();
      final List<ProfileModel> list = snapshot.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return ProfileModel.fromMap(data);
      }).toList();

      final config = await store.collection('Config').doc('profile').get();
      final String selectedId = (config.data()?['selectedId'] as String?) ?? '';

      state = state.copyWith(profileList: list, selectedId: selectedId);
    } catch (e) {
      ToastMessage().ShowToast('프로필을 불러오지 못했습니다.');
    }
  }

  // 프로필 삭제 (Firestore + 메모리, 선택 중이면 선택 해제)
  Future<void> deleteProfile(String id) async {
    try {
      await store.collection('Profiles').doc(id).delete();
      final list = state.profileList.where((p) => p.id != id).toList();
      final String selectedId = state.selectedId == id ? '' : state.selectedId;
      if (state.selectedId == id) {
        await store.collection('Config').doc('profile').set({'selectedId': ''}, SetOptions(merge: true));
      }
      state = state.copyWith(profileList: list, selectedId: selectedId);
    } catch (e) {
      ToastMessage().ShowToast('삭제에 실패했습니다.');
      rethrow;
    }
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
    try {
      for (final id in state.checked) {
        final src = state.profileList.where((p) => p.id == id).toList();
        if (src.isEmpty) continue;
        final newId = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(100000)}';
        final copy = src.first.copyWith(id: newId, name: '${src.first.name ?? '프로필'} 복사');
        await store.collection('Profiles').doc(newId).set(copy.toMap(), SetOptions(merge: true));
      }
      state = state.copyWith(checked: {});
      await getProfiles();
    } catch (e) {
      ToastMessage().ShowToast('복사에 실패했습니다.');
    }
  }

  // 사용할 프로필 선택 (mobile view 연결 대상)
  Future<void> selectProfile(String id) async {
    final String prev = state.selectedId;
    state = state.copyWith(selectedId: id);
    try {
      await store.collection('Config').doc('profile').set({'selectedId': id}, SetOptions(merge: true));
    } catch (e) {
      state = state.copyWith(selectedId: prev); // 실패 시 롤백
      ToastMessage().ShowToast('선택 저장에 실패했습니다.');
    }
  }

  // mobile view용: 현재 선택된 프로필 1건 로드
  Future<ProfileModel?> loadSelected() async {
    try {
      final config = await store.collection('Config').doc('profile').get();
      final String? selectedId = config.data()?['selectedId'] as String?;
      if (selectedId == null || selectedId.isEmpty) return null;
      final doc = await store.collection('Profiles').doc(selectedId).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return ProfileModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }
}

final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController();
});
