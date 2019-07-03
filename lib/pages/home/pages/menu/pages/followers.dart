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

class OBFollowersPage extends StatefulWidget {
  @override
  State<OBFollowersPage> createState() {
    return OBFollowersPageState();
  }
}

class OBFollowersPageState extends State<OBFollowersPage> {
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
        title: 'Followers',
      ),
      child: OBPrimaryColorContainer(
        child: OBHttpList<User>(
          controller: _httpListController,
          listItemBuilder: _buildFollowerListItem,
          searchResultListItemBuilder: _buildFollowerListItem,
          listRefresher: _refreshFollowers,
          listOnScrollLoader: _loadMoreFollowers,
          listSearcher: _searchFollowers,
          resourceSingularName: 'follower',
          resourcePluralName: 'followers',
        ),
      ),
    );
  }

  Widget _buildFollowerListItem(BuildContext context, User user) {
    return OBUserTile(user,
        onUserTilePressed: _onFollowerListItemPressed,
        trailing: OBFollowButton(
          user,
          size: OBButtonSize.small,
          unfollowButtonType: OBButtonType.highlight,
        ));
  }

  void _onFollowerListItemPressed(User follower) {
    _navigationService.navigateToUserProfile(user: follower, context: context);
  }

  Future<List<User>> _refreshFollowers() async {
    UsersList followers = await _userService.getFollowers();
    return followers.users;
  }

  Future<List<User>> _loadMoreFollowers(List<User> followersList) async {
    var lastFollower = followersList.last;
    var lastFollowerId = lastFollower.id;
    var moreFollowers = (await _userService.getFollowers(
      maxId: lastFollowerId,
      count: 20,
    ))
        .users;
    return moreFollowers;
  }

  Future<List<User>> _searchFollowers(String query) async {
    UsersList results = await _userService.searchFollowers(query: query);

    return results.users;
  }
}
