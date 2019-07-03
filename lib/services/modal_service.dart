import 'dart:io';

import 'package:Buzzing/models/circle.dart';
import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/follows_list.dart';
import 'package:Buzzing/models/moderation/moderated_object.dart';
import 'package:Buzzing/models/moderation/moderation_category.dart';
import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/models/post_comment.dart';
import 'package:Buzzing/models/post_reaction.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/models/user_invite.dart';
import 'package:Buzzing/pages/home/modals/accept_guidelines/accept_guidelines.dart';
import 'package:Buzzing/pages/home/modals/edit_post/edit_post.dart';
import 'package:Buzzing/pages/home/modals/invite_to_community.dart';
import 'package:Buzzing/pages/home/modals/post_comment/post-comment-reply-expanded.dart';
import 'package:Buzzing/pages/home/modals/post_comment/post-commenter-expanded.dart';
import 'package:Buzzing/pages/home/pages/community/pages/manage_community/pages/community_administrators/modals/add_community_administrator/add_community_administrator.dart';
import 'package:Buzzing/pages/home/modals/create_post/create_post.dart';
import 'package:Buzzing/pages/home/modals/edit_user_profile/edit_user_profile.dart';
import 'package:Buzzing/pages/home/modals/save_community.dart';
import 'package:Buzzing/pages/home/modals/save_connections_circle.dart';
import 'package:Buzzing/pages/home/modals/save_follows_list/save_follows_list.dart';
import 'package:Buzzing/pages/home/modals/timeline_filters.dart';
import 'package:Buzzing/pages/home/pages/community/pages/manage_community/pages/community_banned_users/modals/ban_community_user/ban_community_user.dart';
import 'package:Buzzing/pages/home/pages/community/pages/manage_community/pages/community_moderators/modals/add_community_moderator/add_community_moderator.dart';
import 'package:Buzzing/pages/home/modals/user_invites/create_user_invite.dart';
import 'package:Buzzing/pages/home/modals/user_invites/send_invite_email.dart';
import 'package:Buzzing/pages/home/pages/moderated_objects/modals/moderated_objects_filters/moderated_objects_filters.dart';
import 'package:Buzzing/pages/home/pages/moderated_objects/moderated_objects.dart';
import 'package:Buzzing/pages/home/pages/moderated_objects/pages/widgets/moderated_object_category/modals/moderated_object_update_category.dart';
import 'package:Buzzing/pages/home/pages/moderated_objects/pages/widgets/moderated_object_description/modals/moderated_object_update_description.dart';
import 'package:Buzzing/pages/home/pages/moderated_objects/pages/widgets/moderated_object_status/modals/moderated_object_update_status.dart';
import 'package:Buzzing/pages/home/pages/timeline/timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModalService {
  Future<Post> openCreatePost(
      {@required BuildContext context,
      Community community,
      String text,
      File image}) async {
    Post createdPost = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<Post>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return Material(
                child: CreatePostModal(
                  community: community,
                  text: text,
                  image: image,
                ),
              );
            }));

    return createdPost;
  }

  Future<Post> openEditPost(
      {@required BuildContext context, @required Post post}) async {
    Post editedPost = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<Post>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return Material(
                child: EditPostModal(
                  post: post,
                ),
              );
            }));

    return editedPost;
  }

  Future<PostComment> openExpandedCommenter(
      {@required BuildContext context,
      @required PostComment postComment,
      @required Post post}) async {
    PostComment editedComment = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<PostComment>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return Material(
                child: OBPostCommenterExpandedModal(
                  post: post,
                  postComment: postComment,
                ),
              );
            }));
    return editedComment;
  }

  Future<PostComment> openExpandedReplyCommenter(
      {@required BuildContext context,
      @required PostComment postComment,
      @required Post post,
      @required Function(PostComment) onReplyAdded,
      @required Function(PostComment) onReplyDeleted}) async {
    PostComment replyComment = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<PostComment>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return Material(
                child: OBPostCommentReplyExpandedModal(
                    post: post,
                    postComment: postComment,
                    onReplyAdded: onReplyAdded,
                    onReplyDeleted: onReplyDeleted),
              );
            }));
    return replyComment;
  }

  Future<void> openEditUserProfile(
      {@required User user, @required BuildContext context}) async {
    Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<PostReaction>(
            fullscreenDialog: true,
            builder: (BuildContext context) => Material(
                  child: OBEditUserProfileModal(user),
                )));
  }

  Future<FollowsList> openCreateFollowsList(
      {@required BuildContext context}) async {
    FollowsList createdFollowsList =
        await Navigator.of(context, rootNavigator: true)
            .push(CupertinoPageRoute<FollowsList>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return OBSaveFollowsListModal(
                    autofocusNameTextField: true,
                  );
                }));

    return createdFollowsList;
  }

  Future<FollowsList> openEditFollowsList(
      {@required FollowsList followsList,
      @required BuildContext context}) async {
    FollowsList editedFollowsList =
        await Navigator.of(context).push(CupertinoPageRoute<FollowsList>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return OBSaveFollowsListModal(
                followsList: followsList,
              );
            }));

    return editedFollowsList;
  }

  Future<Circle> openCreateConnectionsCircle(
      {@required BuildContext context}) async {
    Circle createdConnectionsCircle =
        await Navigator.of(context).push(CupertinoPageRoute<Circle>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return OBSaveConnectionsCircleModal(
                autofocusNameTextField: true,
              );
            }));

    return createdConnectionsCircle;
  }

  Future<Circle> openEditConnectionsCircle(
      {@required Circle connectionsCircle,
      @required BuildContext context}) async {
    Circle editedConnectionsCircle =
        await Navigator.of(context, rootNavigator: true)
            .push(CupertinoPageRoute<Circle>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return Material(
                    child: OBSaveConnectionsCircleModal(
                      connectionsCircle: connectionsCircle,
                    ),
                  );
                }));

    return editedConnectionsCircle;
  }

  Future<Community> openEditCommunity(
      {@required BuildContext context, @required Community community}) async {
    Community editedCommunity = await Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<Community>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return Material(
                child: OBSaveCommunityModal(
                  community: community,
                ),
              );
            }));

    return editedCommunity;
  }

  Future<void> openInviteToCommunity(
      {@required BuildContext context, @required Community community}) async {
    return Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<Community>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return Material(
                child: OBInviteToCommunityModal(
                  community: community,
                ),
              );
            }));
  }

  Future<Community> openCreateCommunity(
      {@required BuildContext context}) async {
    Community createdCommunity =
        await Navigator.of(context, rootNavigator: true)
            .push(CupertinoPageRoute<Community>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return Material(
                    child: OBSaveCommunityModal(),
                  );
                }));

    return createdCommunity;
  }

  Future<User> openAddCommunityAdministrator(
      {@required BuildContext context, @required Community community}) async {
    User addedCommunityAdministrator =
        await Navigator.of(context, rootNavigator: true)
            .push(CupertinoPageRoute<User>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return Material(
                    child: OBAddCommunityAdministratorModal(
                      community: community,
                    ),
                  );
                }));

    return addedCommunityAdministrator;
  }

  Future<User> openAddCommunityModerator(
      {@required BuildContext context, @required Community community}) async {
    User addedCommunityModerator =
        await Navigator.of(context, rootNavigator: true)
            .push(CupertinoPageRoute<User>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return Material(
                    child: OBAddCommunityModeratorModal(
                      community: community,
                    ),
                  );
                }));

    return addedCommunityModerator;
  }

  Future<User> openBanCommunityUser(
      {@required BuildContext context, @required Community community}) async {
    User addedCommunityBannedUser =
        await Navigator.of(context, rootNavigator: true)
            .push(CupertinoPageRoute<User>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return Material(
                    child: OBBanCommunityUserModal(
                      community: community,
                    ),
                  );
                }));

    return addedCommunityBannedUser;
  }

  Future<void> openTimelineFilters(
      {@required OBTimelinePageController timelineController,
      @required BuildContext context}) {
    return Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute<Circle>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return Material(
                child: OBTimelineFiltersModal(
                  timelinePageController: timelineController,
                ),
              );
            }));
  }

  Future<UserInvite> openCreateUserInvite(
      {@required BuildContext context}) async {
    UserInvite createdUserInvite =
        await Navigator.of(context).push(CupertinoPageRoute<UserInvite>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return OBCreateUserInviteModal(
                autofocusNameTextField: true,
              );
            }));

    return createdUserInvite;
  }

  Future<UserInvite> openEditUserInvite(
      {@required BuildContext context, @required UserInvite userInvite}) async {
    UserInvite editedUserInvite =
        await Navigator.of(context).push(CupertinoPageRoute<UserInvite>(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return OBCreateUserInviteModal(
                autofocusNameTextField: true,
                userInvite: userInvite,
              );
            }));

    return editedUserInvite;
  }

  Future<void> openSendUserInviteEmail(
      {@required BuildContext context, @required UserInvite userInvite}) async {
    await Navigator.of(context).push(CupertinoPageRoute<UserInvite>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return OBSendUserInviteEmailModal(
            autofocusEmailTextField: true,
            userInvite: userInvite,
          );
        }));
  }

  Future<void> openModeratedObjectsFilters(
      {@required
          BuildContext context,
      @required
          OBModeratedObjectsPageController
              moderatedObjectsPageController}) async {
    await Navigator.of(context).push(CupertinoPageRoute<UserInvite>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return OBModeratedObjectsFiltersModal(
            moderatedObjectsPageController: moderatedObjectsPageController,
          );
        }));
  }

  Future<void> openAcceptGuidelines({@required BuildContext context}) async {
    await Navigator.of(context).push(CupertinoPageRoute<UserInvite>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return Material(
            child: OBAcceptGuidelinesModal(),
          );
        }));
  }

  Future<String> openModeratedObjectUpdateDescription(
      {@required BuildContext context,
      @required ModeratedObject moderatedObject}) async {
    return Navigator.of(context).push(CupertinoPageRoute<String>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return OBModeratedObjectUpdateDescriptionModal(
            moderatedObject: moderatedObject,
          );
        }));
  }

  Future<ModerationCategory> openModeratedObjectUpdateCategory(
      {@required BuildContext context,
      @required ModeratedObject moderatedObject}) async {
    return Navigator.of(context).push(CupertinoPageRoute<ModerationCategory>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return OBModeratedObjectUpdateCategoryModal(
            moderatedObject: moderatedObject,
          );
        }));
  }

  Future<ModeratedObjectStatus> openModeratedObjectUpdateStatus(
      {@required BuildContext context,
      @required ModeratedObject moderatedObject}) async {
    return Navigator.of(context).push(CupertinoPageRoute<ModeratedObjectStatus>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return OBModeratedObjectUpdateStatusModal(
            moderatedObject: moderatedObject,
          );
        }));
  }
}
