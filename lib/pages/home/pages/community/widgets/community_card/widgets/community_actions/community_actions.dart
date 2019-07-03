import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/pages/home/pages/community/widgets/community_card/widgets/community_actions/widgets/community_action_more/community_action_more.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/navigation_service.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/buttons/actions/join_community_button.dart';
import 'package:Buzzing/widgets/buttons/community_button.dart';
import 'package:flutter/material.dart';

class OBCommunityActions extends StatelessWidget {
  final Community community;

  OBCommunityActions(this.community);

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    NavigationService navigationService = buzzingProvider.navigationService;
    UserService userService = buzzingProvider.userService;

    User loggedInUser = userService.getLoggedInUser();

    bool isCommunityAdmin = community?.isAdministrator(loggedInUser) ?? false;
    bool isCommunityModerator = community?.isModerator(loggedInUser) ?? false;

    List<Widget> actions = [];

    if (isCommunityAdmin || isCommunityModerator) {
      actions.add(_buildManageButton(navigationService, context));
    } else {
      actions.addAll([
        OBJoinCommunityButton(community),
        const SizedBox(
          width: 10,
        ),
        OBCommunityActionMore(community)
      ]);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions,
    );
  }

  _buildManageButton(NavigationService navigationService, context) {
    return OBCommunityButton(
        community: community,
        isLoading: false,
        text: 'Manage',
        onPressed: () {
          navigationService.navigateToManageCommunity(
              community: community, context: context);
        });
  }
}
