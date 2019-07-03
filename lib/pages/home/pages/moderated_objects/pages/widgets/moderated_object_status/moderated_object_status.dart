import 'package:Buzzing/models/moderation/moderated_object.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tile_group_title.dart';
import 'package:Buzzing/widgets/tiles/moderated_object_status_tile.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectStatus extends StatelessWidget {
  final bool isEditable;
  final ModeratedObject moderatedObject;
  final ValueChanged<ModeratedObjectStatus> onStatusChanged;

  const OBModeratedObjectStatus(
      {Key key,
      @required this.moderatedObject,
      @required this.isEditable,
      this.onStatusChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OBTileGroupTitle(
          title: 'Status',
        ),
        StreamBuilder(
          initialData: moderatedObject,
          stream: moderatedObject.updateSubject,
          builder:
              (BuildContext context, AsyncSnapshot<ModeratedObject> snapshot) {
            return OBModeratedObjectStatusTile(
              moderatedObject: moderatedObject,
              trailing: isEditable
                  ? const OBIcon(
                      OBIcons.edit,
                      themeColor: OBIconThemeColor.secondaryText,
                    )
                  : null,
              onPressed: (moderatedObject) async {
                if (!isEditable) return;
                BuzzingProviderState buzzingProvider =
                    BuzzingProvider.of(context);
                ModeratedObjectStatus newModerationStatus =
                    await buzzingProvider.modalService
                        .openModeratedObjectUpdateStatus(
                            context: context, moderatedObject: moderatedObject);
                if (newModerationStatus != null && onStatusChanged != null)
                  onStatusChanged(newModerationStatus);
              },
            );
          },
        ),
      ],
    );
  }
}
