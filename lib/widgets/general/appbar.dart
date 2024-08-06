import 'package:easy_ringtube/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:kh_easy_dev/kh_easy_dev.dart';

appAppBar({
  required String title,
  List<Widget>? actions,
  Widget? developerPage,
  VoidCallback? onBackButtonPreesed,
  BuildContext? context,
  (String, Function(String))? searchAppBar,
}) {
  return kheasydevAppBar(
    title: title,
    logoPath: 'assets/logo.png',
    primaryColor: AppColor.primaryColor,
    shadowColor: AppColor.shadowColor,
    titleColor: Colors.white,
    actions: actions,
    developerPage: developerPage,
    leading: onBackButtonPreesed != null
        ? IconButton(
            onPressed: onBackButtonPreesed, icon: Icon(Icons.arrow_back))
        : null,
    context: context,
    searchAppBar: searchAppBar,
  );
}
