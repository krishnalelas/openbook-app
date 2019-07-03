import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:flutter/material.dart';

class OBCommunityActionMore extends StatelessWidget {
  final Community community;

  const OBCommunityActionMore(this.community);

  @override
  Widget build(BuildContext context) {

    return IconButton(
    icon: const OBIcon(
      OBIcons.moreVertical,
      customSize: 30,
    ),
    onPressed: () {
      BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);
      buzzingProvider.bottomSheetService.showCommunityActions(context: context, community: community);
    },
  );
  }
}
