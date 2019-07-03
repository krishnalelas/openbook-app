import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBPostActionComment extends StatelessWidget {
  final Post _post;
  final VoidCallback onWantsToCommentPost;

  OBPostActionComment(this._post, {this.onWantsToCommentPost});

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    var navigationService = buzzingProvider.navigationService;

    return OBButton(
        type: OBButtonType.highlight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const OBIcon(
              OBIcons.comment,
              customSize: 20.0,
            ),
            const SizedBox(
              width: 10.0,
            ),
            const OBText('Comment'),
          ],
        ),
        onPressed: () {
          if (onWantsToCommentPost != null) {
            onWantsToCommentPost();
          } else {
            navigationService.navigateToCommentPost(
                post: _post, context: context);
          }
        });
  }
}

typedef void OnWantsToCommentPost(Post post);
