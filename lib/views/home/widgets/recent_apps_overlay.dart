import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/controllers/home_controller.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/app_setting.dart';
import 'package:portfolio/core/widgets/empty_state.dart';
import 'package:utility/textstyle.dart';

// 하단 네비 첫번째(메뉴) 버튼 → 최근 연 앱 모아보기 오버레이
class RecentAppsOverlay extends ConsumerWidget {
  const RecentAppsOverlay({super.key});

  // 앱 키 → 표시 아이콘 매핑
  static const Map<String, IconData> _icons = {
    'note': Icons.sticky_note_2_outlined,
    'message': Icons.chat_bubble_outline,
    'calendar': Icons.calendar_today_outlined,
    'profile': Icons.badge_outlined,
    'folder_1': Icons.folder_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool open = ref.watch(homeControllerProvider.select((s) => s.recentOpen));
    final List<String> recents = ref.watch(homeControllerProvider.select((s) => s.recentApps));
    final controller = ref.read(homeControllerProvider.notifier);

    return IgnorePointer(
      ignoring: !open,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: open ? 1 : 0,
        child: GestureDetector(
          onTap: controller.closeRecent,
          child: Container(
            width: app_width,
            height: app_height,
            color: pBackBlack.withValues(alpha: 0.55),
            padding: EdgeInsets.symmetric(vertical: app_width * 0.2, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 16),
                  child: Text('최근 연 앱', style: white(24, FontWeight.w700)),
                ),
                Expanded(
                  child: recents.isEmpty
                      ? const EmptyState(icon: Icons.history, message: '최근 연 앱이 없습니다')
                      : ListView.separated(
                          itemCount: recents.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final String key = recents[index];
                            return GestureDetector(
                              onTap: () {
                                controller.closeRecent();
                                controller.tabIcon(context, key);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: pWhite,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: backSurface,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(_icons[key] ?? Icons.apps, color: secondary, size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(child: Text(controller.returnName(key), style: black(16, FontWeight.w600))),
                                    const Icon(Icons.chevron_right, color: pBackGrey2),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
