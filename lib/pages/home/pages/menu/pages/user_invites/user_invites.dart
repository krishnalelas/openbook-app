import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/models/user_invite.dart';
import 'package:Buzzing/models/user_invites_list.dart';
import 'package:Buzzing/pages/home/pages/menu/pages/user_invites/widgets/my_invite_group.dart';
import 'package:Buzzing/pages/home/pages/menu/pages/user_invites/widgets/user_invite_count.dart';
import 'package:Buzzing/services/modal_service.dart';
import 'package:Buzzing/widgets/alerts/button_alert.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/icon_button.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/widgets/page_scaffold.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Buzzing/services/httpie.dart';

class OBUserInvitesPage extends StatefulWidget {
  @override
  State<OBUserInvitesPage> createState() {
    return OBUserInvitesPageState();
  }
}

class OBUserInvitesPageState extends State<OBUserInvitesPage> {
  UserService _userService;
  ToastService _toastService;
  ModalService _modalService;

  User _user;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  ScrollController _userInvitesScrollController;
  OBMyInvitesGroupController _acceptedInvitesGroupController;
  OBMyInvitesGroupController _pendingInvitesGroupController;

  bool _hasAcceptedInvites;
  bool _hasPendingInvites;
  bool _refreshInProgress;

  CancelableOperation _refreshUserOperation;

  bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _userInvitesScrollController = ScrollController();
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _acceptedInvitesGroupController = OBMyInvitesGroupController();
    _pendingInvitesGroupController = OBMyInvitesGroupController();
    _hasAcceptedInvites = true;
    _hasPendingInvites = true;
    _needsBootstrap = true;
    _refreshInProgress = true;
  }

  @override
  void dispose() {
    super.dispose();
    if (_refreshUserOperation != null) _refreshUserOperation.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = BuzzingProvider.of(context);
      _userService = provider.userService;
      _toastService = provider.toastService;
      _modalService = provider.modalService;
      _user = _userService.getLoggedInUser();
      _bootstrap();
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        navigationBar: OBThemedNavigationBar(
          title: 'My Invites',
          trailing: Opacity(
            opacity: _user.inviteCount == 0 ? 0.5 : 1.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                OBUserInviteCount(
                  count: _user.inviteCount,
                ),
                const SizedBox(
                  width: 10,
                ),
                OBIconButton(
                  OBIcons.add,
                  themeColor: OBIconThemeColor.primaryAccent,
                  onPressed: _onWantsToCreateInvite,
                ),
              ],
            ),
          ),
        ),
        child: Stack(
          children: <Widget>[
            OBPrimaryColorContainer(
                child: Column(
              children: <Widget>[
               _hasAcceptedInvites || _hasPendingInvites
                            ? _buildInvitesList()
                            : _buildNoInvitesFallback()
                ],
              )
            ),
          ],
      ),
    );
  }

  Widget _buildInvitesList() {
    return Expanded(
        child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshInvites,
        child: ListView(
            key: Key('myUserInvites'),
            controller: _userInvitesScrollController,
            // Need always scrollable for pull to refresh to work
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(0),
            children: <Widget>[
              Column(
                children: <Widget>[
                  OBMyInvitesGroup(
                    key: Key('AcceptedInvitesGroup'),
                    controller: _acceptedInvitesGroupController,
                    title: 'Accepted',
                    groupName: 'accepted invites',
                    groupItemName: 'accepted invite',
                    maxGroupListPreviewItems: 5,
                    inviteListSearcher: _searchAcceptedUserInvites,
                    inviteGroupListItemDeleteCallback:
                        _onUserInviteDeletedCallback,
                    inviteGroupListRefresher: _refreshAcceptedInvites,
                    inviteGroupListOnScrollLoader: _loadMoreAcceptedInvites,
                  ),
                  OBMyInvitesGroup(
                    key: Key('PendingInvitesGroup'),
                    controller: _pendingInvitesGroupController,
                    title: 'Pending',
                    groupName: 'pending invites',
                    groupItemName: 'pending invite',
                    maxGroupListPreviewItems: 5,
                    inviteListSearcher: _searchPendingUserInvites,
                    inviteGroupListItemDeleteCallback:
                        _onUserInviteDeletedCallback,
                    inviteGroupListRefresher: _refreshPendingInvites,
                    inviteGroupListOnScrollLoader: _loadMorePendingInvites,
                  ),
                ],
              )
            ]
          ),
        )
    );
  }

  Widget _buildNoInvitesFallback() {
    bool hasInvites = _user.inviteCount > 0;

    String message = hasInvites
        ? 'Looks like you haven\'t used any invite.'
        : 'You have no invites available.';

    String assetImage = hasInvites
        ? 'assets/images/stickers/perplexed-owl.png'
        : 'assets/images/stickers/owl-instructor.png';

    Function _onPressed = hasInvites
        ? _onWantsToCreateInvite
        : _refreshInvites;

    String buttonText = hasInvites
        ? 'Invite a friend'
        : 'Refresh';

    return OBButtonAlert(
      text: message,
      onPressed: _onPressed,
      buttonText: buttonText,
      buttonIcon: hasInvites ? OBIcons.add : OBIcons.refresh,
      isLoading: _refreshInProgress,
      assetImage: assetImage,
    );
  }

  Widget _onUserInviteDeletedCallback(
      BuildContext context, UserInvite userInvite) {
    setState(() {
      if (userInvite.createdUser == null) _user.inviteCount += 1;
    });
  }

  void _bootstrap() async {
    await _refreshInvites();
  }

  Future<void> _refreshInvites() async {
    _setRefreshInProgress(true);
    try {
      await Future.wait([
        _refreshUser(),
        _hasAcceptedInvites ?_acceptedInvitesGroupController.refresh() : _refreshAcceptedInvites(),
        _hasPendingInvites ? _pendingInvitesGroupController.refresh() : _refreshPendingInvites(),
      ]);
      _scrollToTop();
    } catch (error) {
      _onError(error);
    } finally {
      _setRefreshInProgress(false);
    }
  }

  Future<void> _refreshUser() async {
    if (_refreshUserOperation != null) _refreshUserOperation.cancel();
    _refreshUserOperation =
        CancelableOperation.fromFuture(_userService.refreshUser());
    await _refreshUserOperation.value;
    User refreshedUser = _userService.getLoggedInUser();
    setState(() {
      _user = refreshedUser;
    });
  }

  Future<List<UserInvite>> _refreshPendingInvites() async {
    UserInvitesList pendingInvitesList = await _userService.getUserInvites(
        status: UserInviteFilterByStatus.pending);
    _setHasPendingInvites(pendingInvitesList.invites.isNotEmpty);
    return pendingInvitesList.invites;
  }

  Future<List<UserInvite>> _refreshAcceptedInvites() async {
    UserInvitesList acceptedInvitesList = await _userService.getUserInvites(
        status: UserInviteFilterByStatus.accepted);
    _setHasAcceptedInvites(acceptedInvitesList.invites.isNotEmpty);
    return acceptedInvitesList.invites;
  }

  Future<List<UserInvite>> _loadMorePendingInvites(
      List<UserInvite> currentInviteList) async {
    int offset = currentInviteList.length;

    UserInvitesList morePendingInvites = await _userService.getUserInvites(
        offset: offset, status: UserInviteFilterByStatus.pending);
    return morePendingInvites.invites;
  }

  Future<List<UserInvite>> _loadMoreAcceptedInvites(
      List<UserInvite> currentInviteList) async {
    int offset = currentInviteList.length;

    UserInvitesList moreAcceptedInvites = await _userService.getUserInvites(
        offset: offset, status: UserInviteFilterByStatus.accepted);
    return moreAcceptedInvites.invites;
  }

  Future<List<UserInvite>> _searchPendingUserInvites(String query) async {
    UserInvitesList results = await _userService.searchUserInvites(
        query: query, status: UserInviteFilterByStatus.pending);
    return results.invites;
  }

  Future<List<UserInvite>> _searchAcceptedUserInvites(String query) async {
    UserInvitesList results = await _userService.searchUserInvites(
        query: query, status: UserInviteFilterByStatus.accepted);
    return results.invites;
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

  void _onWantsToCreateInvite() async {
    if (_user.inviteCount == 0) {
      _showNoInvitesLeft();
      return;
    }
    UserInvite createdUserInvite =
        await _modalService.openCreateUserInvite(context: context);
    if (createdUserInvite != null) {
      _onUserInviteCreated(createdUserInvite);
    }
  }

  void _showNoInvitesLeft() {
    _toastService.error(message: 'You have no invites available', context: context);
  }

  void _onUserInviteCreated(UserInvite createdUserInvite) {
    _refreshInvites();
    _scrollToTop();
  }

  void _scrollToTop() {
    if (_userInvitesScrollController.hasClients) {
      _userInvitesScrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _setHasAcceptedInvites(bool hasAcceptedInvites) {
    setState(() {
      _hasAcceptedInvites = hasAcceptedInvites;
    });
  }

  void _setHasPendingInvites(bool hasPendingInvites) {
    setState(() {
      _hasPendingInvites = hasPendingInvites;
    });
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }
}

typedef Future<UserInvite> OnWantsToCreateUserInvite();
typedef Future<UserInvite> OnWantsToEditUserInvite(UserInvite userInvite);
typedef void OnWantsToSeeUserInvite(UserInvite userInvite);
