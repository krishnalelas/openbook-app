import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/models/post_comment.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/navigation_service.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:flutter/material.dart';
import 'package:Buzzing/pages/home/pages/post_comments/widgets/post_comment/widgets/post_comment_text.dart';
import 'package:Buzzing/widgets/avatars/avatar.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';


class OBPostCommentTile extends StatelessWidget {
  final PostComment postComment;
  final Post post;

  OBPostCommentTile({
    @required this.post,
    @required this.postComment});

  @override
  Widget build(BuildContext context) {
    var provider = BuzzingProvider.of(context);
    NavigationService _navigationService = provider.navigationService;

    return StreamBuilder(
        key: Key('OBPostCommentTile#${this.postComment.id}'),
        stream: this.postComment.updateSubject,
        initialData: this.postComment,
        builder: (BuildContext context, AsyncSnapshot<PostComment> snapshot) {
          PostComment postComment = snapshot.data;

          return Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                OBAvatar(
                  onPressed: () {
                    _navigationService.navigateToUserProfile(
                        user: postComment.commenter, context: context);
                  },
                  size: OBAvatarSize.small,
                  avatarUrl: postComment.getCommenterProfileAvatar(),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        OBPostCommentText(
                          postComment,
                          badge: _getCommunityBadge(postComment),
                          onUsernamePressed: () {
                            _navigationService.navigateToUserProfile(
                                user: postComment.commenter, context: context);
                          },
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        OBSecondaryText(
                          postComment.getRelativeCreated(),
                          style: TextStyle(fontSize: 12.0),
                        )
                      ],
                    ))
              ],
            ),
          );
        });
  }

  Widget _getCommunityBadge(PostComment postComment) {
    Post post = this.post;
    User postCommenter = postComment.commenter;

    if (post.hasCommunity()) {
      Community postCommunity = post.community;

      bool isCommunityAdministrator =
      postCommenter.isAdministratorOfCommunity(postCommunity);

      if (isCommunityAdministrator) {
        return _buildCommunityAdministratorBadge();
      }

      bool isCommunityModerator =
      postCommenter.isModeratorOfCommunity(postCommunity);

      if (isCommunityModerator) {
        return _buildCommunityModeratorBadge();
      }
    }

    return const SizedBox();
  }

  Widget _buildCommunityAdministratorBadge() {
    return const OBIcon(
      OBIcons.communityAdministrators,
      size: OBIconSize.small,
      themeColor: OBIconThemeColor.primaryAccent,
    );
  }

  Widget _buildCommunityModeratorBadge() {
    return const OBIcon(
      OBIcons.communityModerators,
      size: OBIconSize.small,
      themeColor: OBIconThemeColor.primaryAccent,
    );
  }
}