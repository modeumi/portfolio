// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/legacy.dart';

import 'package:portfolio/models/note_model.dart';
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';

class NoteState {
  final NoteModel note;

  final List<NoteModel> noteList;

  final String sortKey;

  final bool sortType;
  final bool isChange;
  final bool isSaving;

  NoteState({NoteModel? note, this.sortKey = '', List<NoteModel>? noteList, this.sortType = false, this.isChange = false, this.isSaving = false})
    : note = note ?? NoteModel(),
      noteList = noteList ?? [];

  NoteState copyWith({NoteModel? note, String? sortKey, List<NoteModel>? noteList, bool? sortType, bool? isChange, bool? isSaving}) {
    return NoteState(
      note: note ?? this.note,
      sortKey: sortKey ?? this.sortKey,
      sortType: sortType ?? this.sortType,
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
    if (!state.isChange) return;
    state = state.copyWith(isSaving: true, isChange: false);
    DateTime now = DateTime.now();
    String datetime = '${date_to_string_yyyyMMdd('-', now)} ${time_to_string('hms', now)}';
    NoteModel model = state.note;
    if (state.note.createAt == null) {
      model = model.copyWith(createAt: datetime);
    }
    model = model.copyWith(updateAt: datetime);
    state = state.copyWith(note: model);

    Map<String, dynamic> note = state.note.toMap();

    await store.collection('Note').doc(note['id']).set(note, SetOptions(merge: true));

    state = state.copyWith(isSaving: false);
  }

  Future<void> getNotes() async {
    state = state.copyWith(noteList: []);
    QuerySnapshot notes;
    notes = await store.collection('Note').get();
    List<NoteModel> modelList = [];
    for (var i in notes.docs) {
      Map<String, dynamic> data = i.data() as Map<String, dynamic>;
      NoteModel model = NoteModel.fromMap(data);
      modelList.add(model);
    }

    modelList.sort((a, b) {
      DateTime aUpdateDate = DateTime.parse(a.updateAt ?? '1999-12-31');
      DateTime bUpdateDate = DateTime.parse(b.updateAt ?? '1999-12-31');
      return bUpdateDate.compareTo(aUpdateDate);
    });

    state = state.copyWith(noteList: modelList);
  }

  void sortNote() {
    List<NoteModel> modelList = state.noteList;
    String sortKey = state.sortKey;
    bool sortType = state.sortType;
    if (sortKey == 'updateAt') {
      modelList.sort((a, b) {
        DateTime aUpdateDate = DateTime.parse(a.updateAt ?? '1999-12-31');
        DateTime bUpdateDate = DateTime.parse(b.updateAt ?? '1999-12-31');
        return sortType ? bUpdateDate.compareTo(aUpdateDate) : aUpdateDate.compareTo(bUpdateDate);
      });
    } else if (sortKey == 'createAt') {
      modelList.sort((a, b) {
        DateTime aCreateDate = DateTime.parse(a.createAt ?? '1999-12-31');
        DateTime bCreateDate = DateTime.parse(b.createAt ?? '1999-12-31');
        return sortType ? bCreateDate.compareTo(aCreateDate) : aCreateDate.compareTo(bCreateDate);
      });
    } else if (sortKey == 'title') {
      modelList.sort((a, b) {
        String aTitle = (a.title ?? '').toLowerCase();
        String bTitle = (b.title ?? '').toLowerCase();
        if (aTitle == '' && bTitle == '') return 0;
        if (aTitle == '') return 1;
        if (bTitle == '') return -1;
        return sortType ? bTitle.compareTo(aTitle) : aTitle.compareTo(bTitle);
      });
    }
  }

  void setSortInfo(String key, bool type) {
    state = state.copyWith(sortKey: key, sortType: type);
    sortNote();
  }

  void setNote(NoteModel model) {
    state = state.copyWith(note: model);
  }

  Future<void> deleteNote() async {
    await store.collection('Note').doc(state.note.id).delete();
    await getNotes();
  }
}

final noteControllerProvider = StateNotifierProvider<NoteController, NoteState>((ref) {
  return NoteController();
});
