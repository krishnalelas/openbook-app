import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/community_invite.dart';
import 'package:Buzzing/models/notifications/community_invite_notification.dart';
import 'package:Buzzing/models/notifications/notification.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/avatars/avatar.dart';
import 'package:Buzzing/widgets/avatars/community_avatar.dart';
import 'package:Buzzing/widgets/theming/actionable_smart_text.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

class OBCommunityInviteNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final CommunityInviteNotification communityInviteNotification;
  final VoidCallback onPressed;
  static final double postImagePreviewSize = 40;

  const OBCommunityInviteNotificationTile(
      {Key key,
      @required this.notification,
      @required this.communityInviteNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CommunityInvite communityInvite =
        communityInviteNotification.communityInvite;
    User inviteCreator = communityInvite.creator;
    Community community = communityInvite.community;

    String inviteCreatorUsername = inviteCreator.username;
    String communityName = community.name;

    Function navigateToInviteCreatorProfile = () {
      BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);

      buzzingProvider.navigationService
          .navigateToUserProfile(user: inviteCreator, context: context);
    };

    return ListTile(
      onTap: () {
        if (onPressed != null) onPressed();
        BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);

        buzzingProvider.navigationService
            .navigateToCommunity(community: community, context: context);
      },
      leading: OBAvatar(
        onPressed: navigateToInviteCreatorProfile,
        size: OBAvatarSize.medium,
        avatarUrl: inviteCreator.getProfileAvatar(),
      ),
      title: OBActionableSmartText(
        text:
            '@$inviteCreatorUsername has invited you to join community /c/$communityName .',
      ),
      trailing: OBCommunityAvatar(
        community: community,
        size: OBAvatarSize.medium,
      ),
      subtitle: OBSecondaryText(notification.getRelativeCreated()),
    );
  }
}
