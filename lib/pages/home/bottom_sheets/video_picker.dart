import 'dart:io';

import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/image_picker.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBVideoPickerBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ImagePickerService imagePickerService =
        BuzzingProvider.of(context).imagePickerService;

    List<Widget> videoPickerActions = [
      ListTile(
        leading: const OBIcon(OBIcons.gallery),
        title: const OBText(
          'From gallery',
        ),
        onTap: () async {
          File video =
              await imagePickerService.pickVideo(source: ImageSource.gallery);
          Navigator.pop(context, video);
        },
      ),
      ListTile(
        leading: const OBIcon(OBIcons.camera),
        title: const OBText(
          'From camera',
        ),
        onTap: () async {
          File video =
              await imagePickerService.pickVideo(source: ImageSource.camera);
          Navigator.pop(context, video);
        },
      )
    ];

    return OBPrimaryColorContainer(
      mainAxisSize: MainAxisSize.min,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Column(
          children: videoPickerActions,
          mainAxisSize: MainAxisSize.min,
          ),
        )
    );
  }
}
