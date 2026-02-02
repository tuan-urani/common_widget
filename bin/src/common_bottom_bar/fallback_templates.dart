const String fallbackTemplateRouterTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:link_home/src/ui/routing/common_router.dart';

class SettingRouter {
  static String currentRoute = '/';
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    currentRoute = settings.name ?? '/';
    switch (settings.name) {
      default:
        return CommonRouter.onGenerateRoute(settings);
    }
  }
}
''';

const String fallbackCommonRouterTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CommonRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        return null;
    }
  }
}
''';

const String fallbackMainEventTemplate = '''
import 'package:equatable/equatable.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';

abstract class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object?> get props => [];
}

class MainInitialized extends MainEvent {
  const MainInitialized();
}

class OnChangeTabEvent extends MainEvent {
  final BottomNavigationPage page;

  const OnChangeTabEvent(this.page);

  @override
  List<Object?> get props => [page];
}
''';

const String fallbackMainStateTemplate = '''
import 'package:equatable/equatable.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';

class MainState extends Equatable {
  final BottomNavigationPage currentPage;

  const MainState({this.currentPage = BottomNavigationPage.__INITIAL_PAGE__});

  MainState copyWith({BottomNavigationPage? currentPage}) {
    return MainState(currentPage: currentPage ?? this.currentPage);
  }

  @override
  List<Object?> get props => [currentPage];
}
''';

const String fallbackMainBlocTemplate = '''
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/ui/main/bloc/main_event.dart';
import 'package:link_home/src/ui/main/bloc/main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  final List<GlobalKey<NavigatorState>> tabNavKeys = [
__TAB_NAV_KEYS__
  ];

  MainBloc() : super(const MainState()) {
    on<MainInitialized>(_onInitialized);
    on<OnChangeTabEvent>(_onChangeTab);
  }

  void _onInitialized(MainInitialized event, Emitter<MainState> emit) {
    emit(state.copyWith(currentPage: BottomNavigationPage.__INITIAL_PAGE__));
  }

  void _onChangeTab(OnChangeTabEvent event, Emitter<MainState> emit) {
    emit(state.copyWith(currentPage: event.page));
  }
}
''';

const String fallbackMainBindingTemplate = '''
import 'package:get/get.dart';
import 'package:link_home/src/ui/main/bloc/main_bloc.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainBloc>(() => MainBloc());
  }
}
''';

const String fallbackMainPageTemplate = '''
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
''';

const String fallbackBottomNavigationPageTemplate = '''
import 'package:flutter/material.dart';

enum BottomNavigationPage { __ENUM_VALUES__ }

extension BottomNavigationPageExtension on BottomNavigationPage {
  String get nameTab {
    switch (this) {
__NAME_TAB_CASES__
    }
  }

  IconData get activeIcon {
    switch (this) {
__ACTIVE_ICON_CASES__
    }
  }

  IconData get inactiveIcon {
    switch (this) {
__INACTIVE_ICON_CASES__
    }
  }

  IconData getIcon(bool isSelected) {
    return isSelected ? activeIcon : inactiveIcon;
  }
}
''';

const String fallbackAppBottomNavigationBarStandardTemplate = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/ui/main/bloc/main_bloc.dart';
import 'package:link_home/src/ui/main/bloc/main_event.dart';
import 'package:link_home/src/ui/main/bloc/main_state.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      buildWhen:
          (previous, current) => previous.currentPage != current.currentPage,
      builder: (context, state) {
        final bloc = context.read<MainBloc>();
        final tabs = BottomNavigationPage.values;
        final currentIndex = tabs.indexOf(state.currentPage);

        return SizedBox(
          height: 72,
          child: Container(
            height: 72,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildItems(
                  tabs: tabs,
                  currentIndex: currentIndex,
                  onChanged: (page) => bloc.add(OnChangeTabEvent(page)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildItems({
    required List<BottomNavigationPage> tabs,
    required int currentIndex,
    required ValueChanged<BottomNavigationPage> onChanged,
  }) {
    return List.generate(tabs.length, (index) {
      final page = tabs[index];
      final isSelected = currentIndex == index;
      return Expanded(
        child: _TabItem(
          page: page,
          isSelected: isSelected,
          onTap: () => onChanged(page),
        ),
      );
    });
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.page,
    required this.isSelected,
    required this.onTap,
  });

  final BottomNavigationPage page;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.black : const Color(0xFF333333);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.getIcon(isSelected), size: 22, color: color),
          const SizedBox(height: 2),
          Text(
            page.nameTab,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
''';

const String fallbackAppBottomNavigationBarTopNotchTemplate = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_home/src/enums/bottom_navigation_page.dart';
import 'package:link_home/src/ui/main/bloc/main_bloc.dart';
import 'package:link_home/src/ui/main/bloc/main_event.dart';
import 'package:link_home/src/ui/main/bloc/main_state.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    this.onCenterTap,
  });
  final VoidCallback? onCenterTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc, MainState>(
      buildWhen:
          (previous, current) => previous.currentPage != current.currentPage,
      builder: (context, state) {
        final bloc = context.read<MainBloc>();
        final tabs = BottomNavigationPage.values;
        final currentIndex = tabs.indexOf(state.currentPage);

        return SizedBox(
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _buildItemsWithGap(
                      tabs: tabs,
                      currentIndex: currentIndex,
                      onChanged: (page) => bloc.add(OnChangeTabEvent(page)),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: -28,
                child: Center(
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: FloatingActionButton(
                      onPressed: onCenterTap,
                      elevation: 2,
                      backgroundColor: const Color(0xFFEFF8DD),
                      shape: const CircleBorder(),
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildItemsWithGap({
    required List<BottomNavigationPage> tabs,
    required int currentIndex,
    required ValueChanged<BottomNavigationPage> onChanged,
  }) {
    final gapIndex = tabs.length ~/ 2;
    final items = <Widget>[];
    for (var i = 0; i < tabs.length; i++) {
      if (i == gapIndex) {
        items.add(const SizedBox(width: 56));
      }
      final page = tabs[i];
      final isSelected = currentIndex == i;
      items.add(
        Expanded(
          child: _TabItem(
            page: page,
            isSelected: isSelected,
            onTap: () => onChanged(page),
          ),
        ),
      );
    }
    return items;
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.page,
    required this.isSelected,
    required this.onTap,
  });

  final BottomNavigationPage page;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.black : const Color(0xFF333333);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.getIcon(isSelected), size: 22, color: color),
          const SizedBox(height: 2),
          Text(
            page.nameTab,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
''';
