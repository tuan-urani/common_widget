import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:link_home/src/ui/widgets/base/bottom_sheet/pick_time_wheel.dart';
import 'package:link_home/src/utils/app_assets.dart';
import 'package:link_home/src/utils/app_colors.dart';
import 'package:link_home/src/utils/app_styles.dart';

class AppInputYear extends StatefulWidget {
  final String? hint;
  final String? label;
  final int minLines;
  final int maxLines;
  final EdgeInsets? margin;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintTextStyle;
  final Function(int) onYearChanged;
  final int initialYear;
  final int maximumYear;
  final int minimumYear;

  const AppInputYear({
    super.key,
    this.hint,
    this.label,
    this.minLines = 1,
    this.maxLines = 5,
    this.margin,
    this.textStyle,
    this.labelStyle,
    this.hintTextStyle,
    required this.onYearChanged,
    required this.initialYear,
    required this.maximumYear,
    required this.minimumYear,
  });

  @override
  State<AppInputYear> createState() => _AppInputYearState();
}

class _AppInputYearState extends State<AppInputYear> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant AppInputYear oldWidget) {
    super.didUpdateWidget(oldWidget);
      _yearController.text = widget.initialYear.toString();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _yearController.dispose();
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
          showYearWheelPickerBottomSheet(
            initialYear: widget.initialYear,
            minimumYear: widget.minimumYear,
            maximumYear: widget.maximumYear,
            onYearChanged: (int year) {
              widget.onYearChanged(year);
            },
          );
        },
        controller: _yearController,
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
              child: SvgPicture.asset(AppAssets.icons_calendar_svg),
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
