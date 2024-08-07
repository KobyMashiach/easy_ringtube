import 'package:easy_ringtube/core/colors.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final bool unfillColors;
  final EdgeInsets? padding;
  final double? textSize;

  const AppButton({
    super.key,
    this.onTap,
    required this.text,
    this.unfillColors = false,
    this.padding,
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: padding ?? const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: !unfillColors ? AppColor.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: !unfillColors
                ? null
                : Border.all(color: AppColor.primaryColor)),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: !unfillColors ? Colors.white : AppColor.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: textSize ?? 20,
            ),
          ),
        ),
      ),
    );
  }
}
