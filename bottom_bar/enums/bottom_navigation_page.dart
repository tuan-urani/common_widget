import 'package:flutter/material.dart';

enum BottomNavigationPage { home, customer, calendar, setting }

extension BottomNavigationPageExtension on BottomNavigationPage {
  String get nameTab {
    switch (this) {
      case BottomNavigationPage.home:
        return 'ホーム';
      case BottomNavigationPage.customer:
        return '顧客情報';
      case BottomNavigationPage.calendar:
        return 'カレンダー';
      case BottomNavigationPage.setting:
        return 'マニュアル';
    }
  }

  IconData get activeIcon {
    switch (this) {
      case BottomNavigationPage.home:
        return Icons.home;
      case BottomNavigationPage.customer:
        return Icons.people;
      case BottomNavigationPage.calendar:
        return Icons.calendar_month;
      case BottomNavigationPage.setting:
        return Icons.menu_book;
    }
  }

  IconData get inactiveIcon {
    switch (this) {
      case BottomNavigationPage.home:
        return Icons.home_outlined;
      case BottomNavigationPage.customer:
        return Icons.people_outline;
      case BottomNavigationPage.calendar:
        return Icons.calendar_month_outlined;
      case BottomNavigationPage.setting:
        return Icons.menu_book_outlined;
    }
  }

  IconData getIcon(bool isSelected) {
    return isSelected ? activeIcon : inactiveIcon;
  }
}
