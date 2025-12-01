// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/legacy.dart';

import 'package:portfolio/models/note_model.dart';
import 'package:utility/import_package.dart';

class NoteState {
  final NoteModel note;

  final Map<String, List<NoteModel>> noteFolder;

  final List<NoteModel> noteList;

  final bool isChange;
  final bool isSaving;

  NoteState({NoteModel? note, Map<String, List<NoteModel>>? noteFolder, List<NoteModel>? noteList, this.isChange = false, this.isSaving = false})
    : note = note ?? NoteModel(),
      noteFolder = noteFolder ?? {},
      noteList = noteList ?? [];

  NoteState copyWith({NoteModel? note, Map<String, List<NoteModel>>? noteFolder, List<NoteModel>? noteList, bool? isChange, bool? isSaving}) {
    return NoteState(
      note: note ?? this.note,
      noteFolder: noteFolder ?? this.noteFolder,
      noteList: noteList ?? this.noteList,
      isChange: isChange ?? this.isChange,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class NoteController extends StateNotifier<NoteState> {
  Timer? autosave;
  NoteController() : super(NoteState());

  final store = FirebaseFirestore.instance;

  void runAutosave() {
    if (autosave != null) return;

    autosave = Timer.periodic(Duration(seconds: 5), (timer) {
      saveNote();
    });
  }

  void stopAutosave() {
    autosave?.cancel();
    autosave = null;
  }

  void setNoteId() {
    NoteModel note = NoteModel();
    DateTime now = DateTime.now();
    String dayCode = now.toIso8601String();
    int ranCode = Random().nextInt(10000);
    note = note.copyWith(id: '$dayCode-$ranCode');
    state = state.copyWith(note: note);
  }

  void changeNoteState(String key, dynamic value) {
    NoteModel note = state.note;
    if (key == 'star') {
      note = note.copyWith(bookmark: value);
    } else if (key == 'title') {
      note = note.copyWith(title: value);
    } else if (key == 'content') {
      note = note.copyWith(content: value);
    }
    state = state.copyWith(note: note);
  }

  void enterText() {
    state = state.copyWith(isChange: true);
  }

  // 작성된 노트 저장 -> 5초마다 자동저장
  void saveNote() async {
    print(state.isChange);
    if (!state.isChange) return;
    state = state.copyWith(isSaving: true, isChange: false);
    Map<String, dynamic> note = state.note.toMap();
    print(note);
    // String id = note['id'];
    // note.remove('id');

    // await store.collection('Note').doc(id).set(note, SetOptions(merge: true));

    state = state.copyWith(isSaving: false);
  }
}

final noteControllerProvider = StateNotifierProvider<NoteController, NoteState>((ref) {
  return NoteController();
});
