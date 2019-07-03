import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/pages/home/bottom_sheets/post_actions.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/avatars/avatar.dart';
import 'package:Buzzing/widgets/avatars/community_avatar.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCommunityPostHeader extends StatelessWidget {
  final Post _post;
  final OnPostDeleted onPostDeleted;
  final ValueChanged<Post> onPostReported;
  final bool hasActions;

  const OBCommunityPostHeader(this._post,
      {Key key,
      @required this.onPostDeleted,
      this.onPostReported,
      this.hasActions = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    var navigationService = buzzingProvider.navigationService;
    var bottomSheetService = buzzingProvider.bottomSheetService;

    return StreamBuilder(
        stream: _post.community.updateSubject,
        initialData: _post.community,
        builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
          Community community = snapshot.data;

          return ListTile(
            leading: OBAvatar(
              avatarUrl: _post.creator.getProfileAvatar(),
              size: OBAvatarSize.medium,
              onPressed: () {
                navigationService.navigateToUserProfile(
                    user: _post.creator, context: context);
              },
            ),
            trailing: hasActions
                ? IconButton(
                    icon: const OBIcon(OBIcons.moreVertical),
                    onPressed: () {
                      bottomSheetService.showPostActions(
                          context: context,
                          post: _post,
                          onPostDeleted: onPostDeleted,
                          onPostReported: onPostReported);
                    })
                : null,
            title: GestureDetector(
              onTap: () {
                navigationService.navigateToCommunity(
                    community: community, context: context);
              },
              child: Row(
                children: <Widget>[
                  OBCommunityAvatar(
                    borderRadius: 4,
                    customSize: 16,
                    community: community,
                    onPressed: () {
                      navigationService.navigateToCommunity(
                          community: community, context: context);
                    },
                    size: OBAvatarSize.extraSmall,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: OBText(
                      '/c/' + community.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            subtitle: GestureDetector(
              onTap: () {
                navigationService.navigateToUserProfile(
                    user: _post.creator, context: context);
              },
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: OBSecondaryText(
                      '@' + _post.creator.username + ' ',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  OBSecondaryText(
                    _post.getRelativeCreated(),
                    style: TextStyle(fontSize: 12.0),
                  )
                ],
              ),
            ),
          );
        });
  }
}
