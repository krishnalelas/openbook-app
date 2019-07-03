import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/theme.dart';
import 'package:Buzzing/services/theme_value_parser.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/progress_indicator.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tiles/community_tile.dart';
import 'package:Buzzing/widgets/tiles/user_tile.dart';
import 'package:flutter/material.dart';

class OBUserSearchResults extends StatefulWidget {
  final List<User> userResults;
  final List<Community> communityResults;
  final String searchQuery;
  final ValueChanged<User> onUserPressed;
  final ValueChanged<Community> onCommunityPressed;
  final ValueChanged<OBUserSearchResultsTab> onTabSelectionChanged;
  final VoidCallback onScroll;
  final OBUserSearchResultsTab selectedTab;
  final bool userSearchInProgress;
  final bool communitySearchInProgress;

  const OBUserSearchResults(
      {Key key,
      @required this.userResults,
      this.selectedTab = OBUserSearchResultsTab.users,
      @required this.communityResults,
      this.userSearchInProgress = false,
      this.communitySearchInProgress = false,
      @required this.searchQuery,
      @required this.onUserPressed,
      @required this.onScroll,
      @required this.onCommunityPressed,
      @required this.onTabSelectionChanged})
      : super(key: key);

  @override
  OBUserSearchResultsState createState() {
    return OBUserSearchResultsState();
  }
}

class OBUserSearchResultsState extends State<OBUserSearchResults>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    switch (widget.selectedTab) {
      case OBUserSearchResultsTab.users:
        _tabController.index = 0;
        break;
      case OBUserSearchResultsTab.communities:
        _tabController.index = 1;
        break;
      default:
        throw 'Unhandled tab index';
    }

    _tabController.addListener(_onTabSelectionChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.removeListener(_onTabSelectionChanged);
  }

  @override
  Widget build(BuildContext context) {
    BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);
    ThemeService _themeService = buzzingProvider.themeService;
    ThemeValueParserService _themeValueParser =
        buzzingProvider.themeValueParserService;
    OBTheme theme = _themeService.getActiveTheme();

    Color tabIndicatorColor =
        _themeValueParser.parseGradient(theme.primaryAccentColor).colors[1];

    Color tabLabelColor = _themeValueParser.parseColor(theme.primaryTextColor);

    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          tabs: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Tab(text: 'Users'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Tab(text: 'Communities'),
            )
          ],
          isScrollable: false,
          indicatorColor: tabIndicatorColor,
          labelColor: tabLabelColor,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildUserResults(), _buildCommunityResults()],
          ),
        )
      ],
    );
  }

  Widget _buildUserResults() {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        widget.onScroll();
        return true;
      },
      child: ListView.builder(
          padding: EdgeInsets.all(0),
          physics: const ClampingScrollPhysics(),
          itemCount: widget.userResults.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == widget.userResults.length) {
              String searchQuery = widget.searchQuery;
              if (widget.userSearchInProgress) {
                // Search in progress
                return ListTile(
                    leading: OBProgressIndicator(),
                    title: OBText('Searching for $searchQuery'));
              } else if (widget.userResults.isEmpty) {
                // Results were empty
                return ListTile(
                    leading: OBIcon(OBIcons.sad),
                    title: OBText('No users found for $searchQuery.'));
              } else {
                return SizedBox();
              }
            }

            User user = widget.userResults[index];

            return OBUserTile(
              user,
              onUserTilePressed: widget.onUserPressed,
            );
          }),
    );
  }

  Widget _buildCommunityResults() {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        widget.onScroll();
        return true;
      },
      child: ListView.separated(
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 10,
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          physics: const ClampingScrollPhysics(),
          itemCount: widget.communityResults.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == widget.communityResults.length) {
              String searchQuery = widget.searchQuery;
              if (widget.communitySearchInProgress) {
                // Search in progress
                return ListTile(
                    leading: OBProgressIndicator(),
                    title: OBText('Searching for $searchQuery'));
              } else if (widget.communityResults.isEmpty) {
                // Results were empty
                return ListTile(
                    leading: OBIcon(OBIcons.sad),
                    title: OBText('No communities found for $searchQuery.'));
              } else {
                return SizedBox();
              }
            }

            Community community = widget.communityResults[index];

            return OBCommunityTile(
              community,
              onCommunityTilePressed: widget.onCommunityPressed,
            );
          }),
    );
  }

  void _onTabSelectionChanged() {
    OBUserSearchResultsTab newSelection =
        OBUserSearchResultsTab.values[_tabController.previousIndex];
    widget.onTabSelectionChanged(newSelection);
  }
}

enum OBUserSearchResultsTab { communities, users }
