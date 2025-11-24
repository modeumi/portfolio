import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/views/calendar/calendar_add_schedule_page.dart';
import 'package:portfolio/views/calendar/calendar_daliy_schedule_page.dart';
import 'package:portfolio/views/calendar/calendar_detail_page.dart';
import 'package:portfolio/views/calendar/calendar_page.dart';
import 'package:portfolio/views/calendar/calendar_search_page.dart';
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

          GoRoute(
            path: '/',
            pageBuilder: (context, state) => NoTransitionPage(child: HomePage()),
          ),

          GoRoute(path: '/message', builder: (context, state) => MessageListPage()),
          GoRoute(path: '/message_target', builder: (context, state) => MessageTargetPage()),
          GoRoute(path: '/message_chat', builder: (context, state) => MessageChatPage()),

          GoRoute(
            path: '/calendar',
            builder: (context, state) {
              final previous = state.extra as String;
              return CalendarPage(previous: previous);
            },
          ),
          GoRoute(
            path: '/calendar_add_schedule',
            builder: (context, state) {
              final previous = state.extra as String;
              return CalendarAddSchedulePage(previous: previous);
            },
          ),
          GoRoute(path: '/calendar_detail', builder: (context, state) => CalendarDetailPage()),
          GoRoute(path: '/calendar_search', builder: (context, state) => CalendarSearchPage()),
          GoRoute(
            path: '/calendar_daily_schedule',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                opaque: false,
                child: CalendarDaliySchedulePage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              );
            },
          ),
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
