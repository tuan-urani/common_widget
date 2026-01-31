import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:link_home/src/ui/activity/activity_logs_page.dart';
import 'package:link_home/src/ui/auth/change_password/change_password_page.dart';
import 'package:link_home/src/ui/auth/edit_profile/edit_profile_page.dart';
import 'package:link_home/src/ui/common/common_page.dart';
import 'package:link_home/src/ui/common/not_found_page.dart';
import 'package:link_home/src/ui/appointment_detail/appointment_detail_page.dart';
import 'package:link_home/src/ui/create_plan/create_plan_page.dart';
import 'package:link_home/src/ui/notification/binding/notification_binding.dart';
import 'package:link_home/src/ui/notification/notification_page.dart';
import 'package:link_home/src/ui/search_result/search_result_page.dart';
import 'package:link_home/src/ui/work_detail/work_detail.dart';
import 'package:link_home/src/utils/app_demo_data.dart';
import 'package:link_home/src/utils/app_pages.dart';

/// Router chung chứa các page có thể được gọi từ các tab bottom bar 
class CommonRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        // return GetPageRoute(
        //   page: () => const NotFoundPage(),
        //   settings: settings,
        // );
    }
  }
}
