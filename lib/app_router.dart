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
import 'package:portfolio/views/note/note_page.dart';
import 'package:portfolio/views/note/note_write_page.dart';
import 'package:portfolio/views/profile/profile_detail_page.dart';
import 'package:portfolio/views/profile/profile_page.dart';
import 'package:portfolio/views/profile/profile_write_page.dart';
import 'package:portfolio/views/project/project_detail_page.dart';
import 'package:portfolio/views/project/project_write_page.dart';

// 앱/페이지 열림 전환: 가벼운 페이드 + 살짝 위로 슬라이드
// (웹 기본 zoom 전환은 첫 프레임 빌드와 겹쳐 버벅여서 GPU 비용 낮은 전환으로 대체)
CustomTransitionPage<dynamic> _appPage(Widget child) {
  return CustomTransitionPage(
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

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

          GoRoute(path: '/message', pageBuilder: (context, state) => _appPage(MessageListPage())),
          GoRoute(path: '/message_target', pageBuilder: (context, state) => _appPage(MessageTargetPage())),
          GoRoute(path: '/message_chat', pageBuilder: (context, state) => _appPage(MessageChatPage())),

          GoRoute(path: '/note', pageBuilder: (context, state) => _appPage(NotePage())),
          GoRoute(path: '/note_write', pageBuilder: (context, state) => _appPage(NoteWritePage())),

          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) {
              final previous = state.extra as String? ?? '';
              return _appPage(CalendarPage(previous: previous));
            },
          ),
          GoRoute(
            path: '/calendar_add_schedule',
            pageBuilder: (context, state) {
              // 편집 진입(detail)에서는 extra가 없으므로 null 안전 처리
              final previous = state.extra as String? ?? '';
              return _appPage(CalendarAddSchedulePage(previous: previous));
            },
          ),
          GoRoute(path: '/calendar_detail', pageBuilder: (context, state) => _appPage(CalendarDetailPage())),
          GoRoute(path: '/calendar_search', pageBuilder: (context, state) => _appPage(CalendarSearchPage())),

          // 방문자 view(내정보/프로젝트 소개)는 휴대폰 안쪽에서 표시 (작성/관리는 FieldLayout 유지)
          GoRoute(path: '/profile', pageBuilder: (context, state) => _appPage(ProfilePage())),
          GoRoute(path: '/project_detail', pageBuilder: (context, state) => _appPage(ProjectDetailPage())),

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
          GoRoute(path: '/login', pageBuilder: (context, state) => _appPage(LoginPage())),
          GoRoute(path: '/manage', pageBuilder: (context, state) => _appPage(ManagePage())),
          GoRoute(path: '/profile_detail', pageBuilder: (context, state) => _appPage(ProfileDetailPage())),
          GoRoute(path: '/profile_write', pageBuilder: (context, state) => _appPage(ProfileWritePage())),
          GoRoute(path: '/project_write', pageBuilder: (context, state) => _appPage(ProjectWritePage())),
        ],
      ),
    ],
  );
});
