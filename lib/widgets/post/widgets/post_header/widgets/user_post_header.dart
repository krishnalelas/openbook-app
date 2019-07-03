import 'package:Buzzing/models/badge.dart';
import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/pages/home/bottom_sheets/post_actions.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/avatars/avatar.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';
import 'package:Buzzing/widgets/user_badge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBUserPostHeader extends StatelessWidget {
  final Post _post;
  final OnPostDeleted onPostDeleted;
  final ValueChanged<Post> onPostReported;
  final bool hasActions;

  const OBUserPostHeader(this._post,
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

    if (_post.creator == null) return const SizedBox();

    return ListTile(
      leading: StreamBuilder(
          stream: _post.creator.updateSubject,
          initialData: _post.creator,
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            User postCreator = snapshot.data;

            if (!postCreator.hasProfileAvatar()) return const SizedBox();

            return OBAvatar(
              onPressed: () {
                navigationService.navigateToUserProfile(
                    user: postCreator, context: context);
              },
              size: OBAvatarSize.medium,
              avatarUrl: postCreator.getProfileAvatar(),
            );
          }),
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
          navigationService.navigateToUserProfile(
              user: _post.creator, context: context);
        },
        child: StreamBuilder(
            stream: _post.creator.updateSubject,
            initialData: _post.creator,
            builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
              var postCreator = snapshot.data;

              return Row(children: <Widget>[
                OBText(
                  postCreator.username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _getUserBadge(_post.creator)
              ]);
            }),
      ),
      subtitle: _post.created != null
          ? OBSecondaryText(
              _post.getRelativeCreated(),
              style: TextStyle(fontSize: 12.0),
            )
          : const SizedBox(),
    );
  }

  Widget _getUserBadge(User creator) {
    if (creator.hasProfileBadges() && creator.getProfileBadges().length > 0) {
      Badge badge = creator.getProfileBadges()[0];
      return OBUserBadge(badge: badge, size: OBUserBadgeSize.small);
    }
    return const SizedBox();
  }
}
