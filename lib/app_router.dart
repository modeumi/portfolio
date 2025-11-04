import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/views/home/home_page.dart';
import 'package:portfolio/views/layout/field_layout.dart';
import 'package:portfolio/views/loading/loading_page.dart';
import 'package:portfolio/views/layout/phone_layout.dart';
import 'package:portfolio/views/login/login_page.dart';
import 'package:portfolio/views/manage/manage_page.dart';
import 'package:portfolio/views/message/message_chat_page.dart';
import 'package:portfolio/views/message/message_list_page.dart';
import 'package:portfolio/views/message/message_target_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/loading',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return PhoneLayout(child);
        },
        routes: [
          GoRoute(path: '/loading', builder: (context, state) => LoadingPage()),
          GoRoute(path: '/', builder: (context, state) => HomePage()),
          GoRoute(path: '/message', builder: (context, state) => MessageListPage()),
          GoRoute(path: '/message_target', builder: (context, state) => MessageTargetPage()),
          GoRoute(path: '/message_chat', builder: (context, state) => MessageChatPage()),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) {
          return FieldLayout(child);
        },
        routes: [
          GoRoute(path: '/login', builder: (context, state) => LoginPage()),
          GoRoute(path: '/manage', builder: (context, state) => ManagePage()),
        ],
      ),
    ],
  );
});
