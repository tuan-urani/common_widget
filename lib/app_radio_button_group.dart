import 'package:flutter/material.dart';
import 'package:link_home/src/extensions/int_extensions.dart';
import 'package:link_home/src/utils/app_colors.dart';
import 'package:link_home/src/utils/app_styles.dart';

class AppRadioButtonGroup extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onChanged;
  final Axis direction;

  const AppRadioButtonGroup({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final radioButtons =
        options.map((option) {
          return Padding(
            padding: 8.paddingVertical,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: Radio<String>(
                    value: option,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    splashRadius: 20,
                  ),
                ),
                5.width,
                Padding(
                  padding: 2.paddingBottom,
                  child: Text(
                    option,
                    style: AppStyles.bodyLarge(color: AppColors.color333333),
                  ),
                ),
              ],
            ),
          );
        }).toList();

    return RadioGroup<String>(
      groupValue: selectedOption,
      onChanged: onChanged,
      child:
          direction == Axis.vertical
              ? Column(children: radioButtons)
              : Wrap(spacing: 10, runSpacing: 10, children: radioButtons),
    );
  }
}
