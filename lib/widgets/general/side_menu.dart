import 'package:easy_ringtube/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:kh_easy_dev/kh_easy_dev.dart';
import 'package:kh_easy_dev/widgets/navigate_page.dart';
import 'package:easy_ringtube/core/colors.dart';
import 'package:easy_ringtube/core/translates/get_tran.dart';
import 'package:easy_ringtube/widgets/general/appbar.dart';

appSideMenu(BuildContext context, {required int index}) {
  return KheasydevSideMenu(
    selectedIndex: index,
    shadowColor: AppColor.primaryColor,
    disableColor: AppColor.disableColor,
    // appName: 'Iron Post',
    sidebarItems: [
      SideBarModel(
          icon: Icons.home_outlined,
          label: true ? "מסך בית" : appTranslate("home_screen"),
          onTap: () {
            KheasydevNavigatePage().pushAndRemoveUntil(context, HomeScreen());
          }),
    ],
    buttomBackground: AppColor.buttomBackground,
    appBar: appAppBar(title: 'יצירת קשר'),
  );
}
