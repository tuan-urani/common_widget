import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/extensions/color_extension.dart';
import 'package:link_home/src/extensions/int_extensions.dart';
import 'package:link_home/src/ui/main/bloc/main_bloc.dart';
import 'package:link_home/src/ui/main/bloc/main_event.dart';
import 'package:link_home/src/ui/main/bloc/main_state.dart';
import 'package:link_home/src/ui/routing/calendar_router.dart';
import 'package:link_home/src/ui/routing/customer_router.dart';
import 'package:link_home/src/ui/routing/home_router.dart';
import 'package:link_home/src/ui/routing/setting_router.dart';
import 'package:link_home/src/ui/widgets/base/ripple_button.dart';
import 'package:link_home/src/utils/app_assets.dart';
import 'package:link_home/src/utils/app_colors.dart';
import 'package:link_home/src/utils/app_dimensions.dart';
import 'package:link_home/src/utils/app_styles.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      buildWhen:
          (previous, current) => previous.currentPage != current.currentPage,
      builder: (context, state) {
        final bloc = context.read<MainBloc>();
        final currentIndex = BottomNavigationPage.values.indexOf(
          state.currentPage,
        );

        return SizedBox(
          height: AppDimensions.bottomBarHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: AppDimensions.bottomBarHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacityX(0.12),
                      blurRadius: 25.6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTabItem(
                        BottomNavigationPage.home,
                        0,
                        currentIndex,
                        () {
                          if (HomeRouter.currentRoute != '/' &&
                              state.currentPage == BottomNavigationPage.home) {
                            Navigator.of(
                              Get.find<MainBloc>()
                                  .tabNavKeys[0]
                                  .currentState!
                                  .context,
                            ).popUntil(
                              (Route<dynamic> route) =>
                                  route.settings.name == "/",
                            );
                          } else {
                            bloc.add(
                              const OnChangeTabEvent(BottomNavigationPage.home),
                            );
                          }
                        },
                      ),
                      _buildTabItem(
                        BottomNavigationPage.customer,
                        1,
                        currentIndex,
                        () {
                          if (CustomerRouter.currentRoute != '/' &&
                              state.currentPage ==
                                  BottomNavigationPage.customer) {
                            Navigator.of(
                              Get.find<MainBloc>()
                                  .tabNavKeys[0]
                                  .currentState!
                                  .context,
                            ).popUntil(
                              (Route<dynamic> route) =>
                                  route.settings.name == "/",
                            );
                          } else {
                            bloc.add(
                              const OnChangeTabEvent(
                                BottomNavigationPage.customer,
                              ),
                            );
                          }
                        },
                      ),
                      56.width,
                      _buildTabItem(
                        BottomNavigationPage.calendar,
                        2,
                        currentIndex,
                        () {
                          if (CalendarRouter.currentRoute != '/' &&
                              state.currentPage ==
                                  BottomNavigationPage.calendar) {
                            Navigator.of(
                              Get.find<MainBloc>()
                                  .tabNavKeys[0]
                                  .currentState!
                                  .context,
                            ).popUntil(
                              (Route<dynamic> route) =>
                                  route.settings.name == "/",
                            );
                          } else {
                            bloc.add(
                              const OnChangeTabEvent(
                                BottomNavigationPage.calendar,
                              ),
                            );
                          }
                        },
                      ),
                      _buildTabItem(
                        BottomNavigationPage.setting,
                        3,
                        currentIndex,
                        () {
                          if (SettingRouter.currentRoute != '/' &&
                              state.currentPage ==
                                  BottomNavigationPage.setting) {
                            Navigator.of(
                              Get.find<MainBloc>()
                                  .tabNavKeys[0]
                                  .currentState!
                                  .context,
                            ).popUntil(
                              (Route<dynamic> route) =>
                                  route.settings.name == "/",
                            );
                          } else {
                            bloc.add(
                              const OnChangeTabEvent(
                                BottomNavigationPage.setting,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: -40,
                child: Center(
                  child: RippleButton(
                    onTap: () {
                      // Handle add button action
                    },
                    width: 90,
                    height: 90,
                    borderRadius: 63.borderRadiusAll,
                    backgroundColor: AppColors.colorEFF8DD,
                    padding: EdgeInsets.zero,
                    child: SvgPicture.asset(AppAssets.icons_plus_svg),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabItem(
    BottomNavigationPage page,
    int index,
    int currentIndex,
    VoidCallback onTap,
  ) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(page.getIcon(isSelected), size: 22),
            2.height,
            Text(
              page.nameTab,
              style: AppStyles.bodySmall(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.color333333,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
