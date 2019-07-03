import 'package:Buzzing/models/follows_list.dart';
import 'package:Buzzing/pages/home/pages/menu/pages/follows_list/widgets/follows_list_header/widgets/follows_list_name.dart';
import 'package:Buzzing/widgets/emoji_picker/widgets/emoji_groups/widgets/emoji_group/widgets/emoji.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBFollowsListHeader extends StatelessWidget {
  final FollowsList followsList;

  OBFollowsListHeader(this.followsList);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: followsList.updateSubject,
        initialData: followsList,
        builder: (BuildContext context, AsyncSnapshot<FollowsList> snapshot) {
          var followsList = snapshot.data;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: OBFollowsListName(followsList),
                    ),
                    OBEmoji(followsList.emoji, size: OBEmojiSize.large,),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20),
                child: const OBText('Users',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
  }
}
