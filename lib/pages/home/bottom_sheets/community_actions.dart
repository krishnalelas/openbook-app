import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/modal_service.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tiles/actions/favorite_community_tile.dart';
import 'package:Buzzing/widgets/tiles/actions/report_community_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCommunityActionsBottomSheet extends StatefulWidget {
  final Community community;
  final OnCommunityReported onCommunityReported;

  const OBCommunityActionsBottomSheet(
      {Key key, @required this.community, this.onCommunityReported})
      : super(key: key);

  @override
  OBCommunityActionsBottomSheetState createState() {
    return OBCommunityActionsBottomSheetState();
  }
}

class OBCommunityActionsBottomSheetState
    extends State<OBCommunityActionsBottomSheet> {
  UserService _userService;
  ToastService _toastService;
  ModalService _modalService;

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;
    _modalService = buzzingProvider.modalService;

    List<Widget> communityActions = [
      OBFavoriteCommunityTile(
        community: widget.community,
        onFavoritedCommunity: _dismiss,
        onUnfavoritedCommunity: _dismiss,
      )
    ];

    User loggedInUser = _userService.getLoggedInUser();
    Community community = widget.community;

    bool isMemberOfCommunity = community.isMember(loggedInUser);
    bool isCommunityAdministrator = community.isAdministrator(loggedInUser);
    bool isCommunityModerator = community.isModerator(loggedInUser);
    bool communityHasInvitesEnabled = community.invitesEnabled;

    if (communityHasInvitesEnabled && isMemberOfCommunity) {
      communityActions.add(ListTile(
        leading: const OBIcon(OBIcons.communityInvites),
        title: const OBText(
          'Invite people to community',
        ),
        onTap: _onWantsToInvitePeople,
      ));
    }

    if (!isCommunityAdministrator && !isCommunityModerator) {
      communityActions.add(OBReportCommunityTile(
        community: community,
        onWantsToReportCommunity: () {
          Navigator.of(context).pop();
        },
      ));
    }

    return OBPrimaryColorContainer(
      mainAxisSize: MainAxisSize.min,
      child: Column(
        children: communityActions,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }

  Future _onWantsToInvitePeople() async {
    _dismiss();
    _modalService.openInviteToCommunity(
        context: context, community: widget.community);
  }

  void _onWantsToReportCommunity() async {
    _toastService.error(message: 'Not implemented yet', context: context);
    _dismiss();
  }

  void _dismiss() {
    Navigator.pop(context);
  }
}

typedef OnCommunityReported(Community community);
