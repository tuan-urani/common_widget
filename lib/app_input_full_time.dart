import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_home/src/ui/widgets/base/bottom_sheet/pick_time_wheel.dart';
import 'package:link_home/src/utils/app_assets.dart';
import 'package:link_home/src/utils/app_colors.dart';
import 'package:link_home/src/utils/app_styles.dart';
import 'package:link_home/src/utils/app_utils.dart';

class AppInputFullTime extends StatefulWidget {
  final String? hint;
  final String? label;
  final int minLines;
  final int maxLines;
  final EdgeInsets? margin;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintTextStyle;
  final DateTime initialTime;
  final ValueChanged<DateTime> onTimeChanged;
  final int minimumYear;
  final int maximumYear;

  const AppInputFullTime({
    super.key,
    this.hint,
    this.label,
    this.minLines = 1,
    this.maxLines = 5,
    this.margin,
    this.textStyle,
    this.labelStyle,
    this.hintTextStyle,
    required this.initialTime,
    required this.onTimeChanged,
    required this.minimumYear,
    required this.maximumYear,
  });

  @override
  State<AppInputFullTime> createState() => _AppInputFullTimeState();
}

class _AppInputFullTimeState extends State<AppInputFullTime> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant AppInputFullTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTime != widget.initialTime) {
      _timeController.text = AppUtils.formatJapaneseDateTime(
        widget.initialTime,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _focusNode.hasFocus;

    final Color borderColor =
        isFocused ? AppColors.primary : AppColors.colorB8BCC6;

    final Color labelColor =
        isFocused ? AppColors.primary : AppColors.color667394;

    final BorderRadius borderRadius = BorderRadius.circular(12);

    return Container(
      width: double.infinity,
      padding: widget.margin,
      child: TextFormField(
        readOnly: true,
        onTap: () {
          showFullDateTimeWheelPickerBottomSheet(
            initialYear: widget.initialTime.year,
            initialMonth: widget.initialTime.month,
            initialDay: widget.initialTime.day,
            initialHour: widget.initialTime.hour,
            initialMinute: widget.initialTime.minute,
            onDone: (int year, int month, int day, int hour, int minute) {
              widget.onTimeChanged(DateTime(year, month, day, hour, minute));
            },
            minimumYear: widget.minimumYear,
            maximumYear: widget.maximumYear,
          );
        },
        controller: _timeController,
        focusNode: _focusNode,
        minLines: widget.minLines,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle:
              widget.labelStyle ?? AppStyles.bodyMedium(color: labelColor),
          floatingLabelBehavior: FloatingLabelBehavior.always,

          isCollapsed: true,
          hintText: widget.hint,
          hintStyle:
              widget.hintTextStyle ?? AppStyles.bodyMedium(color: labelColor),
          border: InputBorder.none,

          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          suffixIcon: SizedBox(
            width: 26,
            height: 26,
            child: Center(
              child: SvgPicture.asset(AppAssets.icons_calendar_mark_svg),
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor, width: 1),
          ),
        ),
        style:
            widget.textStyle ??
            AppStyles.bodyMedium(color: AppColors.color1D2410),
      ),
    );
  }
}
