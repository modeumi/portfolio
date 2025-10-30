import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/features/home/home_page.dart';
import 'package:portfolio/features/layout/field_layout.dart';
import 'package:portfolio/features/loading/loading_page.dart';
import 'package:portfolio/features/layout/phone_layout.dart';
import 'package:portfolio/features/login/login_page.dart';
import 'package:portfolio/features/manage/manage_page.dart';
import 'package:portfolio/features/message/message_page.dart';

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
          GoRoute(path: '/message', builder: (context, state) => MessagePage()),
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
