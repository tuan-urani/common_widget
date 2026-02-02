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
