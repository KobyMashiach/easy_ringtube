import 'package:easy_ringtube/tests/set_ringtone_service.dart';
import 'package:flutter/material.dart';

void showRingtoneOptionsDialog(BuildContext context, String filePath) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Set Ringtone'),
        content: Text('Choose where to set the ringtone:'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              setRingtoneForPhone(filePath);
            },
            child: Text('Set for Phone'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              selectContactAndSetRingtone(filePath);
            },
            child: Text('Set for Contact'),
          ),
        ],
      );
    },
  );
}
