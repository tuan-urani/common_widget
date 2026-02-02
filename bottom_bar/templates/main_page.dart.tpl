import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/ui/main/bloc/main_bloc.dart';
import 'package:link_home/src/ui/main/bloc/main_event.dart';
import 'package:link_home/src/ui/main/bloc/main_state.dart';
import 'package:link_home/src/ui/main/components/app_bottom_navigation_bar.dart';
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
__CREATE_PAGE_SWITCH__
  }
}
