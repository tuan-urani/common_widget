import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_home/src/extensions/int_extensions.dart';
import 'package:link_home/src/utils/app_assets.dart';

class AppButtonBar extends StatelessWidget {
  const AppButtonBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: 12.paddingLeft,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: SvgPicture.asset(AppAssets.icons_back_svg),
      ),
    );
  }
}

