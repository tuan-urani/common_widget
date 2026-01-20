import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_home/src/extensions/int_extensions.dart';
import 'package:link_home/src/utils/app_assets.dart';
import 'package:link_home/src/utils/app_colors.dart';
import 'package:link_home/src/utils/app_dimensions.dart';
import 'package:link_home/src/utils/app_styles.dart';

class AppCheckbox extends StatelessWidget {
  final String title;
  final bool isChecked;
  final VoidCallback onTap;
  final Color bgActive;
  final double spacing;
  final double iconSize;
  final double? numberCompletedTask;
  final double? totalCompleteTask;

  const AppCheckbox({
    super.key,
    required this.title,
    required this.isChecked,
    required this.onTap,
    this.bgActive = AppColors.colorFE6F4EC,
    this.spacing = 8,
    this.iconSize = 22,
    this.numberCompletedTask,
    this.totalCompleteTask,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isChecked ? AppColors.transparent : AppColors.colorDFE4F5;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppDimensions.allMargins,
        decoration: BoxDecoration(
          color: isChecked ? bgActive : AppColors.white,
          borderRadius: AppDimensions.borderRadius,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child:
                  isChecked
                      ? SvgPicture.asset(AppAssets.icons_checkbox_active_svg)
                      : SvgPicture.asset(AppAssets.icons_checkbox_unactive_svg),
            ),
            spacing.toInt().width,
            Text(
              title,
              style: AppStyles.bodyMedium(color: AppColors.color667394),
            ),
            Spacer(),
            _buildTaskProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskProgress() {
    if (numberCompletedTask != null && totalCompleteTask != null) {
      return Container(
        padding: 8.paddingAll,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.primary : AppColors.colorFBFC9DE,
          borderRadius: 8.borderRadiusAll,
        ),
        child: Text(
          '${numberCompletedTask!.toInt()}/${totalCompleteTask!.toInt()}',
          style: AppStyles.bodyMedium(color: AppColors.white),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
