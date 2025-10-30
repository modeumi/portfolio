import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/app_colors.dart';
import 'package:portfolio/core/widgets/Home/home_icon_field.dart';
import 'package:portfolio/features/home/home_controller.dart';
import 'package:utility/color.dart';
import 'package:utility/import_package.dart';
import 'package:utility/textstyle.dart';

class HomePageView extends ConsumerStatefulWidget {
  const HomePageView({super.key});

  @override
  ConsumerState<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends ConsumerState<HomePageView> {
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    return Column(
      children: [
        Expanded(
          child: CarouselSlider(
            carouselController: controller.pageController,
            options: CarouselOptions(
              initialPage: homeState.pageNumber,
              height: double.infinity,
              enableInfiniteScroll: false,
              enlargeCenterPage: false,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                controller.setPageNumber(index);
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
                    Flexible(
                      flex: 1,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: pWhite, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 1, color: color_black)),
                              ),
                              child: Row(
                                spacing: 10,
                                children: [
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(10), child: SvgPicture.asset('images/note.svg')),
                                  ),
                                  Text('노트', style: black(18, FontWeight.w600)),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      //TODO : 리마인더 이동 로직 작성
                                    },
                                    child: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: Center(child: Text('작성된 노트가 없습니다.', style: black(18, FontWeight.w500))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: pWhite, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(width: 1, color: color_black)),
                              ),
                              child: Row(
                                spacing: 10,
                                children: [
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: ClipRRect(borderRadius: BorderRadiusGeometry.circular(10), child: SvgPicture.asset('images/reminder.svg')),
                                  ),
                                  Text('리마인더', style: black(18, FontWeight.w600)),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      //TODO : 리마인더 이동 로직 작성
                                    },
                                    child: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: Center(child: Text('등록된 일정이 없습니다.', style: black(18, FontWeight.w500))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                    controller.pushPageIcon(i);
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
