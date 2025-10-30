// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:utility/import_package.dart';

class MessageState {
  final List<dynamic> messages;

  MessageState({List<dynamic>? messages}) : messages = messages ?? [];

  MessageState copyWith({List<dynamic>? messages}) {
    return MessageState(messages: messages ?? this.messages);
  }
}

class MessageController extends StateNotifier<MessageState> {
  MessageController() : super(MessageState());

  DocumentSnapshot? lastDoc;

  final store = FirebaseFirestore.instance;

  void tabBack(BuildContext context) {
    context.go('/');
  }

  Future<void> getMessage() async {
    final docs = await store.collection('messages').orderBy('createdAt').limit(10).get();

    lastDoc = docs.docs.last;

    List<dynamic> messages = state.messages;

    messages.addAll(docs.docs);

    state = state.copyWith(messages: messages);
  }
}

final messageControllerProvider = StateNotifierProvider<MessageController, MessageState>((ref) => MessageController());
