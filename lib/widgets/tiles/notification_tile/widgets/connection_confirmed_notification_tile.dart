import 'package:Buzzing/models/notifications/connection_confirmed_notification.dart';
import 'package:Buzzing/models/notifications/notification.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/avatars/avatar.dart';
import 'package:Buzzing/widgets/theming/actionable_smart_text.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';

class OBConnectionConfirmedNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final ConnectionConfirmedNotification connectionConfirmedNotification;
  final VoidCallback onPressed;

  const OBConnectionConfirmedNotificationTile(
      {Key key,
      @required this.notification,
      @required this.connectionConfirmedNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String connectionConfirmatorUsername =
        connectionConfirmedNotification.connectionConfirmator.username;
    return ListTile(
      onTap: () {
        if (onPressed != null) onPressed();
        BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);

        buzzingProvider.navigationService.navigateToUserProfile(
            user: connectionConfirmedNotification.connectionConfirmator,
            context: context);
      },
      leading: OBAvatar(
        size: OBAvatarSize.medium,
        avatarUrl: connectionConfirmedNotification.connectionConfirmator
            .getProfileAvatar(),
      ),
      title: OBActionableSmartText(
        text:
            '@$connectionConfirmatorUsername accepted your connection request.',
      ),
      subtitle: OBSecondaryText(notification.getRelativeCreated()),
    );
  }
}
