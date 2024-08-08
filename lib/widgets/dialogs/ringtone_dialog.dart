import 'package:flutter/material.dart';

import 'package:kh_easy_dev/kh_easy_dev.dart';

class RingtoneDialog extends StatelessWidget {
  const RingtoneDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return KheasydevDialog(
      primaryColor: Colors.white,
      title: "הגדר צלצול",
      buttons: [
        GenericButtonModel(
            text: "צלצול לפלאפון",
            type: GenericButtonType.outlined,
            onPressed: () {
              Navigator.of(context).pop("phone");
            }),
        GenericButtonModel(
          text: "צלצול לאיש קשר",
          type: GenericButtonType.outlined,
          onPressed: () {
            Navigator.of(context).pop("contact");
          },
        ),
      ],
    );
  }
}
