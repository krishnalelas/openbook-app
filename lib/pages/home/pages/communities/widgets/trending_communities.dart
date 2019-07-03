import 'package:Buzzing/models/category.dart';
import 'package:Buzzing/models/communities_list.dart';
import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/navigation_service.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/alerts/button_alert.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tiles/community_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBTrendingCommunities extends StatefulWidget {
  final Category category;
  final ScrollController scrollController;

  const OBTrendingCommunities({Key key, this.category, this.scrollController})
      : super(key: key);

  @override
  OBTrendingCommunitiesState createState() {
    return OBTrendingCommunitiesState();
  }
}

class OBTrendingCommunitiesState extends State<OBTrendingCommunities>
    with AutomaticKeepAliveClientMixin {
  bool _needsBootstrap;
  UserService _userService;
  ToastService _toastService;
  NavigationService _navigationService;
  List<Community> _trendingCommunities;
  bool _refreshInProgress;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _trendingCommunities = [];
    _refreshInProgress = false;
    _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var buzzingProvider = BuzzingProvider.of(context);
      _userService = buzzingProvider.userService;
      _toastService = buzzingProvider.toastService;
      _navigationService = buzzingProvider.navigationService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return RefreshIndicator(
      onRefresh: _refreshTrendingCommunities,
      key: _refreshIndicatorKey,
      displacement: 80,
      child: ListView(
        // BUG https://github.com/flutter/flutter/issues/22180
        //controller: widget.scrollController,
        padding: EdgeInsets.all(0),
        children: <Widget>[
          _trendingCommunities.isEmpty && !_refreshInProgress
              ? _buildNoTrendingCommunities()
              : _buildTrendingCommunities()
        ],
      ),
    );
  }

  Widget _buildNoTrendingCommunities() {
    return OBButtonAlert(
      text: 'No trending communities found. Try again in a few minutes.',
      onPressed: _refreshTrendingCommunities,
      buttonText: 'Refresh',
      buttonIcon: OBIcons.refresh,
      assetImage: 'assets/images/stickers/perplexed-owl.png',
      isLoading: _refreshInProgress,
    );
  }

  Widget _buildTrendingCommunities() {
    bool hasCategory = widget.category != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: OBText(
            hasCategory
                ? 'Trending in ' + widget.category.title
                : 'Trending in all categories',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            controller: widget.scrollController,
            separatorBuilder: _buildCommunitySeparator,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            shrinkWrap: true,
            itemCount: _trendingCommunities.length,
            itemBuilder: _buildCommunity)
      ],
    );
  }

  Widget _buildCommunity(BuildContext context, index) {
    Community community = _trendingCommunities[index];
    return OBCommunityTile(
      community,
      key: Key(community.name),
      onCommunityTilePressed: _onTrendingCommunityPressed,
    );
  }

  Widget _buildCommunitySeparator(BuildContext context, int index) {
    return const SizedBox(
      height: 10,
    );
  }

  void _bootstrap() {
    Future.delayed(
        Duration(
          milliseconds: 0,
        ), () {
      _refreshIndicatorKey.currentState.show();
    });
  }

  Future<void> _refreshTrendingCommunities() async {
    debugPrint('Refreshing trending communities');
    _setRefreshInProgress(true);
    try {
      CommunitiesList trendingCommunitiesList =
          await _userService.getTrendingCommunities(category: widget.category);
      _setTrendingCommunities(trendingCommunitiesList.communities);
    } catch (error) {
      _onError(error);
    } finally {
      _setRefreshInProgress(false);
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

  void _onTrendingCommunityPressed(Community community) {
    _navigationService.navigateToCommunity(
        community: community, context: context);
  }

  void _setTrendingCommunities(List<Community> communities) {
    setState(() {
      _trendingCommunities = communities;
    });
  }

  void _setRefreshInProgress(bool refreshInProgress) {
    setState(() {
      _refreshInProgress = refreshInProgress;
    });
  }

  @override
  bool get wantKeepAlive => true;
}
