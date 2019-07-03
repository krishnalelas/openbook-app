import 'dart:async';

import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/models/users_list.dart';
import 'package:Buzzing/services/modal_service.dart';
import 'package:Buzzing/services/navigation_service.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/widgets/http_list.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/icon_button.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/widgets/page_scaffold.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tiles/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCommunityAdministratorsPage extends StatefulWidget {
  final Community community;

  const OBCommunityAdministratorsPage({Key key, @required this.community})
      : super(key: key);

  @override
  State<OBCommunityAdministratorsPage> createState() {
    return OBCommunityAdministratorsPageState();
  }
}

class OBCommunityAdministratorsPageState
    extends State<OBCommunityAdministratorsPage> {
  UserService _userService;
  ModalService _modalService;
  NavigationService _navigationService;
  ToastService _toastService;

  OBHttpListController _httpListController;
  bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _httpListController = OBHttpListController();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = BuzzingProvider.of(context);
      _userService = provider.userService;
      _modalService = provider.modalService;
      _navigationService = provider.navigationService;
      _toastService = provider.toastService;
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: 'Administrators',
        trailing: OBIconButton(
          OBIcons.add,
          themeColor: OBIconThemeColor.primaryAccent,
          onPressed: _onWantsToAddNewAdministrator,
        ),
      ),
      child: OBPrimaryColorContainer(
        child: OBHttpList<User>(
          controller: _httpListController,
          listItemBuilder: _buildCommunityAdministratorListItem,
          searchResultListItemBuilder: _buildCommunityAdministratorListItem,
          listRefresher: _refreshCommunityAdministrators,
          listOnScrollLoader: _loadMoreCommunityAdministrators,
          listSearcher: _searchCommunityAdministrators,
          resourceSingularName: 'administrator',
          resourcePluralName: 'administrators',
        ),
      ),
    );
  }

  Widget _buildCommunityAdministratorListItem(BuildContext context, User user) {
    bool isLoggedInUser = _userService.isLoggedInUser(user);

    return OBUserTile(
      user,
      onUserTilePressed: _onCommunityAdministratorListItemPressed,
      onUserTileDeleted:
          isLoggedInUser ? null : _onCommunityAdministratorListItemDeleted,
      trailing: isLoggedInUser
          ? OBText(
              'You',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  void _onCommunityAdministratorListItemPressed(User communityAdministrator) {
    _navigationService.navigateToUserProfile(
        user: communityAdministrator, context: context);
  }

  void _onCommunityAdministratorListItemDeleted(
      User communityAdministrator) async {
    try {
      await _userService.removeCommunityAdministrator(
          community: widget.community, user: communityAdministrator);
      _httpListController.removeListItem(communityAdministrator);
    } catch (error) {
      _onError(error);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }

  Future<List<User>> _refreshCommunityAdministrators() async {
    UsersList communityAdministrators =
        await _userService.getAdministratorsForCommunity(widget.community);
    return communityAdministrators.users;
  }

  Future<List<User>> _loadMoreCommunityAdministrators(
      List<User> communityAdministratorsList) async {
    var lastCommunityAdministrator = communityAdministratorsList.last;
    var lastCommunityAdministratorId = lastCommunityAdministrator.id;
    var moreCommunityAdministrators =
        (await _userService.getAdministratorsForCommunity(
      widget.community,
      maxId: lastCommunityAdministratorId,
      count: 20,
    ))
            .users;
    return moreCommunityAdministrators;
  }

  Future<List<User>> _searchCommunityAdministrators(String query) async {
    UsersList results = await _userService.searchCommunityAdministrators(
        query: query, community: widget.community);

    return results.users;
  }

  void _onWantsToAddNewAdministrator() async {
    User addedCommunityAdministrator =
        await _modalService.openAddCommunityAdministrator(
            context: context, community: widget.community);

    if (addedCommunityAdministrator != null) {
      _httpListController.insertListItem(addedCommunityAdministrator);
    }
  }
}

typedef Future<User> OnWantsToCreateCommunityAdministrator();
typedef Future<User> OnWantsToEditCommunityAdministrator(
    User communityAdministrator);
typedef void OnWantsToSeeCommunityAdministrator(User communityAdministrator);
