import 'package:flutter/material.dart';
import 'package:link_home/src/utils/app_assets.dart';
import 'package:link_home/src/utils/app_colors.dart';
import 'package:link_home/src/utils/app_styles.dart';

class AppInput extends StatefulWidget {
  final String? hint;
  final String? label;
  final TextEditingController? controller;
  final int minLines;
  final int maxLines;
  final TextInputType keyboardType;
  final EdgeInsets? margin;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? labelTextStyle;
  final bool isPassword;
  final bool isDisabledTyping;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final VoidCallback? onPressed;

  const AppInput({
    super.key,
    this.hint,
    this.label,
    this.controller,
    this.minLines = 1,
    this.maxLines = 5,
    this.keyboardType = TextInputType.text,
    this.margin,
    this.textStyle,
    this.labelStyle,
    this.hintTextStyle,
    this.labelTextStyle,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.isDisabledTyping = false,

    this.onPressed,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  final FocusNode _focusNode = FocusNode();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
        readOnly: widget.isDisabledTyping,
        controller: widget.controller,
        focusNode: _focusNode,
        onTap: widget.isDisabledTyping ? widget.onPressed : null,
        keyboardType:
            widget.isPassword
                ? TextInputType.visiblePassword
                : widget.keyboardType,

        obscureText: widget.isPassword ? _obscure : false,

        minLines: widget.minLines,
        maxLines: widget.isPassword ? 1 : widget.maxLines,

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

          prefixIcon:
              widget.prefixIcon != null
                  ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: widget.prefixIcon,
                  )
                  : null,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon:
              widget.isPassword
                  ? IconButton(
                    icon: _obscure ? Icon(Icons.visibility_off) : Icon(Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                  : widget.suffixIcon != null
                  ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget.suffixIcon,
                  )
                  : null,

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
