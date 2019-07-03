import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/moderation/moderated_object.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectActions extends StatelessWidget {
  final Community community;
  final ModeratedObject moderatedObject;

  OBModeratedObjectActions(
      {@required this.community, @required this.moderatedObject});

  @override
  Widget build(BuildContext context) {
    List<Widget> moderatedObjectActions = [
      Expanded(
          child: OBButton(
              type: OBButtonType.highlight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const OBIcon(
                    OBIcons.reviewModeratedObject,
                    customSize: 20.0,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  const OBText('Review'),
                ],
              ),
              onPressed: () {
                BuzzingProviderState buzzingProvider =
                    BuzzingProvider.of(context);
                if (community != null) {
                  buzzingProvider.navigationService
                      .navigateToModeratedObjectCommunityReview(
                          moderatedObject: moderatedObject,
                          community: community,
                          context: context);
                } else {
                  buzzingProvider.navigationService
                      .navigateToModeratedObjectGlobalReview(
                          moderatedObject: moderatedObject, context: context);
                }
              })),
    ];

    return Padding(
        padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: moderatedObjectActions,
            )
          ],
        ));
  }
}
