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
