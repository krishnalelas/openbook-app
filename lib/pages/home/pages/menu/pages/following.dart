import 'dart:async';

import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/models/users_list.dart';
import 'package:Buzzing/services/navigation_service.dart';
import 'package:Buzzing/widgets/buttons/actions/follow_button.dart';
import 'package:Buzzing/widgets/http_list.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/widgets/page_scaffold.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:Buzzing/widgets/tiles/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBFollowingPage extends StatefulWidget {
  @override
  State<OBFollowingPage> createState() {
    return OBFollowingPageState();
  }
}

class OBFollowingPageState extends State<OBFollowingPage> {
  UserService _userService;
  NavigationService _navigationService;

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
      _navigationService = provider.navigationService;
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: 'Following',
      ),
      child: OBPrimaryColorContainer(
        child: OBHttpList<User>(
          controller: _httpListController,
          listItemBuilder: _buildFollowingListItem,
          searchResultListItemBuilder: _buildFollowingListItem,
          listRefresher: _refreshFollowing,
          listOnScrollLoader: _loadMoreFollowing,
          listSearcher: _searchFollowing,
          resourceSingularName: 'following',
          resourcePluralName: 'following',
        ),
      ),
    );
  }

  Widget _buildFollowingListItem(BuildContext context, User user) {
    return OBUserTile(user,
        onUserTilePressed: _onFollowingListItemPressed,
        trailing: OBFollowButton(
          user,
          size: OBButtonSize.small,
          unfollowButtonType: OBButtonType.highlight,
        ));
  }

  void _onFollowingListItemPressed(User following) {
    _navigationService.navigateToUserProfile(user: following, context: context);
  }

  Future<List<User>> _refreshFollowing() async {
    UsersList following = await _userService.getFollowings();
    return following.users;
  }

  Future<List<User>> _loadMoreFollowing(List<User> followingList) async {
    var lastFollowing = followingList.last;
    var lastFollowingId = lastFollowing.id;
    var moreFollowing = (await _userService.getFollowings(
      maxId: lastFollowingId,
      count: 20,
    ))
        .users;
    return moreFollowing;
  }

  Future<List<User>> _searchFollowing(String query) async {
    UsersList results = await _userService.searchFollowings(query: query);

    return results.users;
  }
}
