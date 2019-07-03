import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/widgets/post/widgets/post-actions/post_actions.dart';
import 'package:Buzzing/widgets/post/widgets/post-body/post_body.dart';
import 'package:Buzzing/widgets/post/widgets/post-body/widgets/post_body_text.dart';
import 'package:Buzzing/widgets/post/widgets/post_circles.dart';
import 'package:Buzzing/widgets/post/widgets/post_comments/post_comments.dart';
import 'package:Buzzing/widgets/post/widgets/post_header/post_header.dart';
import 'package:Buzzing/widgets/post/widgets/post_reactions/post_reactions.dart';
import 'package:Buzzing/widgets/theming/post_divider.dart';
import 'package:flutter/material.dart';

class OBPost extends StatelessWidget {
  final Post post;
  final ValueChanged<Post> onPostDeleted;
  final OnTextExpandedChange onTextExpandedChange;

  const OBPost(this.post,
      {Key key, @required this.onPostDeleted, this.onTextExpandedChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OBPostHeader(
          post: post,
          onPostDeleted: onPostDeleted,
          onPostReported: onPostDeleted,
        ),
        OBPostBody(
          post,
          onTextExpandedChange: onTextExpandedChange,
        ),
        OBPostReactions(post),
        OBPostCircles(post),
        OBPostComments(
          post,
        ),
        OBPostActions(
          post,
        ),
        const SizedBox(
          height: 16,
        ),
        OBPostDivider(),
      ],
    );
  }
}
