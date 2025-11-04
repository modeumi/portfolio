// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/controllers/layout_controller.dart';
import 'package:portfolio/models/message_chat_model.dart';
import 'package:portfolio/models/message_target_model.dart';
import 'package:utility/crypto.dart';
import 'package:utility/fire_base.dart';
import 'package:utility/import_package.dart';
import 'package:utility/modal_widget.dart';

class MessageState {
  final bool loading;
  final MessageTargetModel? target;
  final List<MessageTargetModel> targets;
  final List<MessageTargetModel> searchTargets;
  final List<MessageChatModel> chats;

  MessageState({
    this.loading = false,
    this.target,
    List<MessageTargetModel>? targets,
    List<MessageTargetModel>? searchTargets,
    List<MessageChatModel>? chats,
  }) : targets = targets ?? [],
       chats = chats ?? [],
       searchTargets = searchTargets ?? [];

  MessageState copyWith({
    bool? loading,
    MessageTargetModel? target,
    List<MessageTargetModel>? targets,
    List<MessageTargetModel>? searchTargets,
    List<MessageChatModel>? chats,
  }) {
    return MessageState(
      loading: loading ?? this.loading,
      target: target,
      targets: targets ?? this.targets,
      searchTargets: searchTargets ?? this.searchTargets,
      chats: chats ?? this.chats,
    );
  }
}

class MessageController extends StateNotifier<MessageState> {
  final Ref ref;
  MessageController(this.ref) : super(MessageState());

  DocumentSnapshot? lastDoc;

  final store = FirebaseFirestore.instance;

  void withLoading() {}

  void tabBack(BuildContext context) {
    context.pop();
    ref.read(layoutControllerProvider.notifier).changeColor(false);
  }

  void searchTarget(BuildContext context, String search) {
    state = state.copyWith(target: null);
    for (var i in state.targets) {
      if (i.name == search) {
        state = state.copyWith(target: i);
      }
    }

    if (state.target == null) {
      String searchTarget = search.characters.take(15).toString();
      state = state.copyWith(target: MessageTargetModel.fromMap({'name': searchTarget}));
    }

    context.pop();
    context.push('/message_chat');
  }

  bool checkAdmin() {
    final admin = FirebaseAuth.instance.currentUser;
    if (admin != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> sendChat(String message, String password, bool lock, bool admin) async {
    bool firstChat = state.chats.isEmpty;
    if (!firstChat) {
      String userPassword = cryption(false, state.target!.password!);
      if (userPassword != password) {
        return 'password';
      }
    }

    Map<String, String> times = Get_Times();
    String createAt = '${times['date']} ${times['time']}';
    String user = admin ? 'Modeumi' : state.target!.name!;
    Map<String, dynamic> messageData = {
      createAt: {'user': user, 'message': message},
    };
    Map<String, dynamic> infoData = {'password': cryption(true, password), 'lock': lock, 'lastDate': times['date'], 'lastContent': message};

    try {
      await store.collection('Message').doc(state.target!.name).set(messageData, SetOptions(merge: true));
      await store.collection('ChatUserInfo').doc(state.target!.name).set(messageData, SetOptions(merge: true));
      return 'pass';
    } catch (e) {
      print(e);
      return 'error';
    }
  }

  Future<void> loadChat(String name) async {
    DocumentSnapshot messages = await store.collection('Message').doc(name).get();
    print(messages.data());
  }

  Future<void> loadChatList() async {
    try {
      QuerySnapshot chatList = await store.collection('ChatUserInfo').get();
      List<MessageTargetModel> models = [];
      for (var i in chatList.docs) {
        Map<String, dynamic> docs = i.data() as Map<String, dynamic>;
        docs['name'] = i.id;

        MessageTargetModel model = MessageTargetModel.fromMap(docs);
        models.add(model);
        print(model.toMap());
      }
      state = state.copyWith(targets: models);
    } catch (e) {
      print('요청에러 $e');
    }
  }

  void setTarget(MessageTargetModel model) {
    state = state.copyWith(target: model);
  }

  bool checkPassword(String password) {
    String decryptPassword = cryption(false, state.target!.password!);
    if (decryptPassword == password) {
      return true;
    } else {
      return false;
    }
  }
}

final messageControllerProvider = StateNotifierProvider<MessageController, MessageState>((ref) => MessageController(ref));
