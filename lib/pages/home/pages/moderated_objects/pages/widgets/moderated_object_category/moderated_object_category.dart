import 'package:Buzzing/models/moderation/moderated_object.dart';
import 'package:Buzzing/models/moderation/moderation_category.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tile_group_title.dart';
import 'package:Buzzing/widgets/tiles/moderation_category_tile.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectCategory extends StatelessWidget {
  final bool isEditable;
  final ModeratedObject moderatedObject;
  final ValueChanged<ModerationCategory> onCategoryChanged;

  const OBModeratedObjectCategory(
      {Key key,
      @required this.moderatedObject,
      @required this.isEditable,
      this.onCategoryChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OBTileGroupTitle(
          title: 'Category',
        ),
        StreamBuilder(
          initialData: moderatedObject,
          stream: moderatedObject.updateSubject,
          builder:
              (BuildContext context, AsyncSnapshot<ModeratedObject> snapshot) {
            return OBModerationCategoryTile(
              category: snapshot.data.category,
              onPressed: (category) async {
                if (!isEditable) return;
                BuzzingProviderState buzzingProvider =
                    BuzzingProvider.of(context);
                ModerationCategory newModerationCategory =
                    await buzzingProvider.modalService
                        .openModeratedObjectUpdateCategory(
                            context: context, moderatedObject: moderatedObject);
                if (newModerationCategory != null && onCategoryChanged != null)
                  onCategoryChanged(newModerationCategory);
              },
              trailing: isEditable ? const OBIcon(
                OBIcons.edit,
                themeColor: OBIconThemeColor.secondaryText,
              ) : null,
            );
          },
        ),
      ],
    );
  }
}
