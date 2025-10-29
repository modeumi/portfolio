import 'package:flutter_riverpod/legacy.dart';

class ManageState {}

class ManageController extends StateNotifier<ManageState> {
  ManageController() : super(ManageState());
}

final manageControllerProvider = StateNotifierProvider<ManageController, ManageState>((ref) {
  return ManageController();
});
