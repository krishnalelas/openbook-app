import 'package:Buzzing/libs/pretty_count.dart';
import 'package:Buzzing/models/follows_list.dart';
import 'package:Buzzing/widgets/checkbox.dart';
import 'package:Buzzing/widgets/emoji_picker/widgets/emoji_groups/widgets/emoji_group/widgets/emoji.dart';
import 'package:Buzzing/widgets/follows_lists_horizontal_list/follows_lists_horizontal_list.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBFollowsListHorizontalListItem extends StatelessWidget {
  final bool isSelected;
  final FollowsList followsList;
  final OnFollowsListPressed onFollowsListPressed;
  final bool wasPreviouslySelected;

  OBFollowsListHorizontalListItem(this.followsList,
      {@required this.onFollowsListPressed,
      this.isSelected,
      this.wasPreviouslySelected = false});

  @override
  Widget build(BuildContext context) {
    int usersCount = followsList.followsCount;

    if (wasPreviouslySelected) {
      if (!isSelected) {
        usersCount = usersCount - 1;
      }
    } else if (isSelected) {
      usersCount = usersCount + 1;
    }
    String prettyUsersCount = getPrettyCount(usersCount);

    return GestureDetector(
      onTap: () {
        if (this.onFollowsListPressed != null) {
          this.onFollowsListPressed(followsList);
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 90, minWidth: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                OBEmoji(followsList.emoji, size: OBEmojiSize.large,),
                Positioned(
                  child: OBCheckbox(
                    value: isSelected,
                  ),
                  bottom: -5,
                  right: -5,
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            OBText(
              followsList.name,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
            OBText(
              prettyUsersCount + ' ' + (usersCount <= 1 ? 'Account' : 'Accounts'),
              maxLines: 1,
              size: OBTextSize.extraSmall,
              style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
