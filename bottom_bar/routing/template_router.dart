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
