import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/moderation/moderated_object.dart';
import 'package:Buzzing/models/post_comment.dart';
import 'package:Buzzing/pages/home/pages/post_comments/widgets/post_comment/post_comment.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/post/widgets/post-body/post_body.dart';
import 'package:Buzzing/widgets/post/widgets/post_header/post_header.dart';
import 'package:Buzzing/widgets/tiles/community_tile.dart';
import 'package:Buzzing/widgets/tiles/user_tile.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectPreview extends StatelessWidget {
  final ModeratedObject moderatedObject;

  const OBModeratedObjectPreview({Key key, @required this.moderatedObject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget widget;

    switch (moderatedObject.type) {
      case ModeratedObjectType.post:
        widget = Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            OBPostHeader(
              post: moderatedObject.contentObject,
              hasActions: false,
            ),
            OBPostBody(moderatedObject.contentObject),
          ],
        );
        break;
      case ModeratedObjectType.community:
        widget = Padding(
          padding: EdgeInsets.all(10),
          child: OBCommunityTile(
            moderatedObject.contentObject,
            onCommunityTilePressed: (Community community) {
              BuzzingProviderState buzzingProvider =
                  BuzzingProvider.of(context);
              buzzingProvider.navigationService
                  .navigateToCommunity(community: community, context: context);
            },
          ),
        );
        break;
      case ModeratedObjectType.postComment:
        PostComment postComment = moderatedObject.contentObject;
        widget = Column(
          children: <Widget>[
            OBPostComment(
              post: postComment.post,
              postComment: moderatedObject.contentObject,
            ),
          ],
        );
        break;
      case ModeratedObjectType.user:
        widget = Column(
          children: <Widget>[
            OBUserTile(moderatedObject.contentObject),
          ],
        );
        break;
      default:
        widget = const SizedBox();
    }
    return widget;
  }
}
