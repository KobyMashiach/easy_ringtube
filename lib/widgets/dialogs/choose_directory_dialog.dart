import 'package:easy_ringtube/core/consts.dart';
import 'package:easy_ringtube/widgets/design/buttons/app_button.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kh_easy_dev/kh_easy_dev.dart';

class DirectoryPickerDialog extends StatefulWidget {
  const DirectoryPickerDialog({super.key});

  @override
  _DirectoryPickerDialogState createState() => _DirectoryPickerDialogState();
}

class _DirectoryPickerDialogState extends State<DirectoryPickerDialog> {
  String? _directoryPath;

  Future<void> _pickDirectory({bool? downloadDirectory}) async {
    final String? directoryPath = downloadDirectory == true
        ? downloadPath
        : await FilePicker.platform.getDirectoryPath();

    setState(() {
      _directoryPath = directoryPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return KheasydevDialog(
        primaryColor: Colors.white,
        title: "בחר תיקייה",
        buttons: [
          GenericButtonModel(
            text: "אישור",
            type: GenericButtonType.outlined,
            disabled: _directoryPath == null,
            onPressed: _directoryPath != null
                ? () {
                    Navigator.of(context).pop(_directoryPath);
                  }
                : null,
          ),
          GenericButtonModel(
            text: "ביטול",
            type: GenericButtonType.outlined,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(
                  text: "בחר תיקייה",
                  textSize: 12,
                  padding: EdgeInsets.zero,
                  onTap: () async => await _pickDirectory(),
                ),
                AppButton(
                  text: "בחר תיקיית הורדות",
                  textSize: 12,
                  padding: EdgeInsets.zero,
                  unfillColors: true,
                  onTap: () async =>
                      await _pickDirectory(downloadDirectory: true),
                ),
              ],
            ),
            SizedBox(height: 12),
            _directoryPath != null
                ? Text("תיקייה נבחרה: $_directoryPath")
                : SizedBox.shrink()
          ],
        ));
  }
}
