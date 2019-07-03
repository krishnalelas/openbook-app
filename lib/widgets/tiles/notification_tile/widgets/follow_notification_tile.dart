import 'package:Buzzing/models/notifications/follow_notification.dart';
import 'package:Buzzing/models/notifications/notification.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/avatars/avatar.dart';
import 'package:Buzzing/widgets/theming/actionable_smart_text.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

class OBFollowNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final FollowNotification followNotification;
  final VoidCallback onPressed;

  const OBFollowNotificationTile(
      {Key key, @required this.notification, @required this.followNotification, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String followerUsername = followNotification.follower.username;
    return ListTile(
      onTap: () {
        if (onPressed != null) onPressed();
        BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);

        buzzingProvider.navigationService.navigateToUserProfile(
            user: followNotification.follower, context: context);
      },
      leading: OBAvatar(
        size: OBAvatarSize.medium,
        avatarUrl: followNotification.follower.getProfileAvatar(),
      ),
      title: OBActionableSmartText(
        text: '@$followerUsername is now following you.',
      ),
      subtitle: OBSecondaryText(notification.getRelativeCreated()),
    );
  }
}
