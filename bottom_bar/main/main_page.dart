import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/ui/calendar/binding/calendar_binding.dart';
import 'package:link_home/src/ui/calendar/bloc/calendar_bloc.dart';
import 'package:link_home/src/ui/customer/binding/customer_binding.dart';
import 'package:link_home/src/ui/customer/bloc/customer_bloc.dart';
import 'package:link_home/src/ui/home/binding/home_binding.dart';
import 'package:link_home/src/ui/home/bloc/home_bloc.dart';
import 'package:link_home/src/ui/main/bloc/main_bloc.dart';
import 'package:link_home/src/ui/main/bloc/main_event.dart';
import 'package:link_home/src/ui/main/bloc/main_state.dart';
import 'package:link_home/src/ui/main/components/app_bottom_navigation_bar.dart';
import 'package:link_home/src/ui/routing/calendar_router.dart';
import 'package:link_home/src/ui/routing/customer_router.dart';
import 'package:link_home/src/ui/routing/home_router.dart';
import 'package:link_home/src/ui/routing/setting_router.dart';
import 'package:link_home/src/ui/setting/binding/setting_binding.dart';
import 'package:link_home/src/ui/setting/bloc/setting_bloc.dart';
import 'package:link_home/src/utils/app_colors.dart';

Map<BottomNavigationPage, Widget> pages = {};

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Get.find<MainBloc>()..add(const MainInitialized()),
      child: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.transparent,
            extendBody: true,
            extendBodyBehindAppBar: true,
            body: BlocBuilder<MainBloc, MainState>(
              buildWhen:
                  (previous, current) =>
                      previous.currentPage != current.currentPage,
              builder: (context, state) {
                _createPage(state.currentPage, context);
                return IndexedStack(
                  sizing: StackFit.expand,
                  index: pages.keys.toList().indexOf(state.currentPage),
                  children: pages.values.toList(),
                );
              },
            ),
            bottomNavigationBar: const AppBottomNavigationBar(),
          );
        },
      ),
    );
  }

  void _createPage(BottomNavigationPage currentPage, BuildContext context) {
    final bloc = context.read<MainBloc>();
    switch (currentPage) {
      case BottomNavigationPage.home:
        if (!Get.isRegistered<HomeBloc>()) {
          HomeBinding().dependencies();
        }
        pages.putIfAbsent(
          currentPage,
          () => CupertinoTabView(
            navigatorKey: bloc.tabNavKeys[0],
            onGenerateRoute: HomeRouter.onGenerateRoute,
          ),
        );
        break;
      case BottomNavigationPage.customer:
        if (!Get.isRegistered<CustomerBloc>()) {
          CustomerBinding().dependencies();
        }
        pages.putIfAbsent(
          currentPage,
          () => CupertinoTabView(
            navigatorKey: bloc.tabNavKeys[1],
            onGenerateRoute: CustomerRouter.onGenerateRoute,
          ),
        );
        break;
      case BottomNavigationPage.calendar:
        if (!Get.isRegistered<CalendarBloc>()) {
          CalendarBinding().dependencies();
        }
        pages.putIfAbsent(
          currentPage,
          () => CupertinoTabView(
            navigatorKey: bloc.tabNavKeys[2],
            onGenerateRoute: CalendarRouter.onGenerateRoute,
          ),
        );
        break;
      case BottomNavigationPage.setting:
        if (!Get.isRegistered<SettingBloc>()) {
          SettingBinding().dependencies();
        }
        pages.putIfAbsent(
          currentPage,
          () => CupertinoTabView(
            navigatorKey: bloc.tabNavKeys[3],
            onGenerateRoute: SettingRouter.onGenerateRoute,
          ),
        );
        break;
    }
  }
}
