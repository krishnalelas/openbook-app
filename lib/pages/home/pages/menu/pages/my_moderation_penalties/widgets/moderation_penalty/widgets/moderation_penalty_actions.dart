import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/moderation/moderated_object.dart';
import 'package:Buzzing/models/moderation/moderation_penalty.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBModerationPenaltyActions extends StatelessWidget {
  final ModerationPenalty moderationPenalty;

  OBModerationPenaltyActions({@required this.moderationPenalty});

  @override
  Widget build(BuildContext context) {
    List<Widget> moderationPenaltyActions = [
      Expanded(
          child: OBButton(
              type: OBButtonType.highlight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const OBIcon(
                    OBIcons.chat,
                    customSize: 20.0,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  const OBText('Chat with the team'),
                ],
              ),
              onPressed: () {
                BuzzingProviderState buzzingProvider =
                    BuzzingProvider.of(context);
                buzzingProvider.intercomService.displayMessenger();
              })),
    ];

    return Padding(
        padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: moderationPenaltyActions,
            )
          ],
        ));
  }
}
