import 'package:Buzzing/models/notifications/connection_request_notification.dart';
import 'package:Buzzing/models/notifications/notification.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/avatars/avatar.dart';
import 'package:Buzzing/widgets/theming/actionable_smart_text.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

class OBConnectionRequestNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final ConnectionRequestNotification connectionRequestNotification;
  final VoidCallback onPressed;

  const OBConnectionRequestNotificationTile(
      {Key key,
      @required this.notification,
      @required this.connectionRequestNotification, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String connectionRequesterUsername =
        connectionRequestNotification.connectionRequester.username;
    return ListTile(
      onTap: () {
        if (onPressed != null) onPressed();
        BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);

        buzzingProvider.navigationService.navigateToUserProfile(
            user: connectionRequestNotification.connectionRequester,
            context: context);
      },
      leading: OBAvatar(
        size: OBAvatarSize.medium,
        avatarUrl: connectionRequestNotification.connectionRequester
            .getProfileAvatar(),
      ),
      title: OBActionableSmartText(
        text: '@$connectionRequesterUsername wants to connect with you.',
      ),
      subtitle: OBSecondaryText(notification.getRelativeCreated()),
    );
  }
}
