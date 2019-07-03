import 'package:Buzzing/models/notifications/notification.dart';
import 'package:Buzzing/models/notifications/post_reaction_notification.dart';
import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/models/post_reaction.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/avatars/avatar.dart';
import 'package:Buzzing/widgets/emoji_picker/widgets/emoji_groups/widgets/emoji_group/widgets/emoji.dart';
import 'package:Buzzing/widgets/theming/actionable_smart_text.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

class OBPostReactionNotificationTile extends StatelessWidget {
  final OBNotification notification;
  final PostReactionNotification postReactionNotification;
  static final double postImagePreviewSize = 40;
  final VoidCallback onPressed;

  const OBPostReactionNotificationTile(
      {Key key,
      @required this.notification,
      @required this.postReactionNotification,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    PostReaction postReaction = postReactionNotification.postReaction;
    Post post = postReaction.post;
    String postReactorUsername = postReaction.getReactorUsername();

    Widget postImagePreview;
    if (post.hasImage()) {
      postImagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image(
          image: AdvancedNetworkImage(post.getImage(), useDiskCache: true),
          height: postImagePreviewSize,
          width: postImagePreviewSize,
          fit: BoxFit.cover,
        ),
      );
    }

    Function navigateToReactorProfile = () {
      BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);

      buzzingProvider.navigationService
          .navigateToUserProfile(user: postReaction.reactor, context: context);
    };

    return ListTile(
      onTap: () {
        if (onPressed != null) onPressed();
        BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);
        buzzingProvider.navigationService
            .navigateToPost(post: postReaction.post, context: context);
      },
      leading: OBAvatar(
        onPressed: navigateToReactorProfile,
        size: OBAvatarSize.medium,
        avatarUrl: postReaction.reactor.getProfileAvatar(),
      ),
      title: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          OBActionableSmartText(
            text: '@$postReactorUsername reacted:',
          ),
          OBEmoji(
            postReaction.emoji,
          ),
        ],
      ),
      trailing: postImagePreview,
      subtitle: OBSecondaryText(notification.getRelativeCreated()),
    );
  }
}
