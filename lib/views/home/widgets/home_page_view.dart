import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/riverpod_mixin.dart';
import 'package:portfolio/views/home/widgets/home_calendar.dart';
import 'package:portfolio/views/home/widgets/home_icon_field.dart';
import 'package:portfolio/views/home/widgets/home_note.dart';
import 'package:utility/import_package.dart';

class HomePageView extends ConsumerStatefulWidget {
  const HomePageView({super.key});

  @override
  ConsumerState<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends ConsumerState<HomePageView> with RiverpodMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CarouselSlider(
            carouselController: homeController.pageController,
            options: CarouselOptions(
              initialPage: homeState.pageNumber,
              height: double.infinity,
              enableInfiniteScroll: false,
              enlargeCenterPage: false,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                homeController.setPageNumber(index);
              },
            ),
            items: [
              SizedBox(
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    HomeIconField(iconData: homeState.apps['profile'], showContent: true),
                    Spacer(),
                    HomeIconField(iconData: homeState.apps['mainMenu'], showContent: true),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                height: double.infinity,
                child: Column(
                  spacing: 20,
                  children: [
                    Flexible(flex: 1, child: HomeNote()),
                    Flexible(flex: 2, child: HomeCalendar()),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: Row(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < 2; i++)
                GestureDetector(
                  onTap: () {
                    homeController.pushPageIcon(i);
                  },
                  child: SvgPicture.asset('images/${i == 0 ? 'home' : 'menu'}_icon.svg', color: homeState.pageNumber == i ? pWhite : null),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
