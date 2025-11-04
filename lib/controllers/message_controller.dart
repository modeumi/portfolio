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
import 'package:utility/format.dart';
import 'package:utility/import_package.dart';

class MessageState {
  final bool loading;
  final MessageTargetModel? target;
  final List<MessageTargetModel> targets;
  final List<MessageTargetModel> searchTargets;
  final Map<String, Map<String, List<MessageChatModel>>> chats;

  MessageState({
    this.loading = false,
    this.target,
    List<MessageTargetModel>? targets,
    List<MessageTargetModel>? searchTargets,
    Map<String, Map<String, List<MessageChatModel>>>? chats,
  }) : targets = targets ?? [],
       chats = chats ?? {},
       searchTargets = searchTargets ?? [];

  MessageState copyWith({
    bool? loading,
    MessageTargetModel? target,
    List<MessageTargetModel>? targets,
    List<MessageTargetModel>? searchTargets,
    Map<String, Map<String, List<MessageChatModel>>>? chats,
  }) {
    return MessageState(
      loading: loading ?? this.loading,
      target: target ?? this.target,
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
    MessageTargetModel model = MessageTargetModel();
    for (var i in state.targets) {
      if (i.name == search) {
        model = i;
      }
    }

    if (model.name == null) {
      String searchTarget = search.characters.take(15).toString();
      model = model.copyWith(name: searchTarget, lock: false);
    }

    state = state.copyWith(target: model);

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

  Future<String> sendChat(String message, String password, bool answer, bool lock) async {
    bool firstChat = state.chats.isEmpty;
    if (!firstChat) {
      String userPassword = cryption(false, state.target!.password!);
      if (userPassword != password && !answer) {
        return 'password';
      }
    }

    Map<String, String> times = Get_Times();
    String createAt = '${times['date']} ${times['time']}';
    String user = answer ? 'Modeumi' : state.target!.name!;

    Map<String, dynamic> messageData = {
      createAt: {'name': user, 'message': message},
    };

    Map<String, dynamic> infoData = {'lastDate': times['date'], 'lastContent': message};

    if (!answer) {
      infoData['password'] = cryption(true, password);
      infoData['lock'] = state.target!.lastContent != null ? state.target!.lock : lock;
    }

    try {
      await store.collection('Message').doc(state.target!.name!).set(messageData, SetOptions(merge: true));
      if (!answer) {
        await store.collection('ChatUserInfo').doc(state.target!.name!).set(infoData, SetOptions(merge: true));
        MessageTargetModel model = MessageTargetModel.fromMap(infoData);
        model = model.copyWith(name: state.target!.name);
        state = state.copyWith(target: model);
      }
      return 'pass';
    } catch (e) {
      print(e);
      return 'error';
    }
  }

  Future<void> loadChat() async {
    try {
      state = state.copyWith(chats: {});
      DocumentSnapshot messages = await store.collection('Message').doc(state.target!.name).get();
      if (messages.data() != null) {
        Map<String, dynamic> result = messages.data() as Map<String, dynamic>;
        List<String> key = result.keys.toList();

        key.sort((a, b) {
          DateTime aDate = DateTime.parse(a);
          DateTime bDate = DateTime.parse(b);
          return aDate.compareTo(bDate);
        });
        Map<String, dynamic> sortResult = {};
        for (String k in key) {
          sortResult[k] = result[k];
        }

        Map<String, Map<String, List<MessageChatModel>>> chats = {};
        int userCount = 0;
        int adminCount = 0;
        for (var i in sortResult.entries) {
          Map<String, dynamic> data = i.value;
          String date = date_to_string_yyyyMMdd('kor_date', DateTime.parse(i.key));
          String time = reforme_time_short('m:', i.key);
          String keyTime = reforme_time_short(':', i.key);

          if (!chats.containsKey(date)) {
            chats[date] = {};
          }
          data['createAt'] = time;
          // 각 list 생성부분에서 다른 count를 올려줌으로서 다음 채팅이 다른 사용자일때 다른 list를 만들어 저장해줌
          if (i.value['name'] == state.target!.name) {
            if (!chats[date]!.containsKey('user${userCount}_$keyTime')) {
              chats[date]!['user${userCount}_$keyTime'] = [];
              adminCount++;
            }
            MessageChatModel model = MessageChatModel.fromMap(data);
            chats[date]!['user${userCount}_$keyTime']!.add(model);
          } else {
            if (!chats[date]!.containsKey('admin${adminCount}_$keyTime')) {
              chats[date]!['admin${adminCount}_$keyTime'] = [];
              userCount++;
            }
            MessageChatModel model = MessageChatModel.fromMap(data);
            chats[date]!['admin${adminCount}_$keyTime']!.add(model);
          }
        }

        state = state.copyWith(chats: chats);
      }
    } catch (e) {
      print('채팅 로드 에러 : $e');
    }
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
      }
      state = state.copyWith(targets: models);
    } catch (e) {
      print('요청에러 $e');
    }
  }

  void setTarget(MessageTargetModel model) {
    state = state.copyWith(target: model);
  }

  Future<void> setLock() async {
    await store.collection('ChatUserInfo').doc(state.target!.name).set({'lock': !state.target!.lock!}, SetOptions(merge: true));
    MessageTargetModel model = state.target!;
    model = model.copyWith(lock: !model.lock!);
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
