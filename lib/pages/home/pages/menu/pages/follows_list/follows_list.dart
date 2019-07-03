import 'package:Buzzing/models/follows_list.dart';
import 'package:Buzzing/pages/home/pages/menu/pages/follows_list/widgets/follows_list_header/follows_list_header.dart';
import 'package:Buzzing/pages/home/pages/menu/pages/follows_list/widgets/follows_list_users.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/widgets/page_scaffold.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/theming/primary_accent_text.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Buzzing/services/httpie.dart';

class OBFollowsListPage extends StatefulWidget {
  final FollowsList followsList;

  OBFollowsListPage(this.followsList);

  @override
  State<OBFollowsListPage> createState() {
    return OBFollowsListPageState();
  }
}

class OBFollowsListPageState extends State<OBFollowsListPage> {
  UserService _userService;
  ToastService _toastService;

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;
  bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;
    var modalService = buzzingProvider.modalService;

    if (_needsBootstrap) {
      _bootstrap();
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        navigationBar: OBThemedNavigationBar(
          trailing: GestureDetector(
            onTap: () {
              modalService.openEditFollowsList(
                  followsList: widget.followsList, context: context);
            },
            child: OBPrimaryAccentText('Edit'),
          ),
        ),
        child: RefreshIndicator(
            key: _refreshIndicatorKey,
            child: OBPrimaryColorContainer(
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    OBFollowsListHeader(widget.followsList),
                    Expanded(
                      child: OBFollowsListUsers(widget.followsList),
                    ),
                  ],
                ),
              ),
            ),
            onRefresh: _refreshFollowsList));
  }

  void _bootstrap() async {
    await _refreshFollowsList();
  }

  Future<void> _refreshFollowsList() async {
    try {
      await _userService.getFollowsListWithId(widget.followsList.id);
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
}
