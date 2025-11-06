import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/controllers/calendar_controller.dart';
import 'package:portfolio/controllers/home_controller.dart';
import 'package:portfolio/controllers/layout_controller.dart';
import 'package:portfolio/controllers/loading_controller.dart';
import 'package:portfolio/controllers/login_controller.dart';
import 'package:portfolio/controllers/manage_controller.dart';
import 'package:portfolio/controllers/message_controller.dart';

mixin RiverpodMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  HomeController get homeController => ref.read(homeControllerProvider.notifier);
  HomeState get homeState => ref.watch(homeControllerProvider);

  LayoutController get layoutController => ref.read(layoutControllerProvider.notifier);
  LayoutState get layoutState => ref.watch(layoutControllerProvider);

  LoadingController get loadingController => ref.read(loadingControllerProvider.notifier);
  LoadingState get loadingState => ref.watch(loadingControllerProvider);

  LoginController get loginController => ref.read(loginControllerProvider.notifier);
  LoginState get loginState => ref.watch(loginControllerProvider);

  ManageController get manageController => ref.read(manageControllerProvider.notifier);
  ManageState get manageState => ref.watch(manageControllerProvider);

  MessageController get messageController => ref.read(messageControllerProvider.notifier);
  MessageState get messageState => ref.watch(messageControllerProvider);

  CalendarController get calendarController => ref.read(calendarControllerProvider.notifier);
  CalendarState get calendarState => ref.watch(calendarControllerProvider);
}
