import 'package:Buzzing/models/circle.dart';
import 'package:Buzzing/models/follows_list.dart';
import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/pages/home/lib/poppable_page_controller.dart';
import 'package:Buzzing/pages/home/pages/timeline/widgets/timeline-posts.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/modal_service.dart';
import 'package:Buzzing/widgets/badges/badge.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/buttons/floating_action_button.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/icon_button.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/widgets/page_scaffold.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBTimelinePage extends StatefulWidget {
  final OBTimelinePageController controller;

  OBTimelinePage({
    @required this.controller,
  });

  @override
  OBTimelinePageState createState() {
    return OBTimelinePageState();
  }
}

class OBTimelinePageState extends State<OBTimelinePage> {
  OBTimelinePostsController _timelinePostsController;
  ModalService _modalService;

  @override
  void initState() {
    super.initState();
    _timelinePostsController = OBTimelinePostsController();
    widget.controller.attach(context: context, state: this);
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _modalService = buzzingProvider.modalService;

    return OBCupertinoPageScaffold(
        navigationBar: OBThemedNavigationBar(
            title: 'Home', trailing: _buildFiltersButton()),
        child: OBPrimaryColorContainer(
          child: Stack(
            children: <Widget>[
              OBTimelinePosts(
                controller: _timelinePostsController,
              ),
              Positioned(
                  bottom: 20.0,
                  right: 20.0,
                  child: OBFloatingActionButton(
                      type: OBButtonType.primary,
                      onPressed: () async {
                        Post createdPost = await _modalService.openCreatePost(
                            context: context);
                        if (createdPost != null) {
                          _timelinePostsController.addPostToTop(createdPost);
                          _timelinePostsController.scrollToTop();
                        }
                      },
                      child: const OBIcon(OBIcons.createPost,
                          size: OBIconSize.large, color: Colors.white)))
            ],
          ),
        ));
  }

  Widget _buildFiltersButton() {
    int filtersCount = _timelinePostsController.isAttached()
        ? _timelinePostsController.countFilters()
        : 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OBBadge(
          count: filtersCount,
        ),
        const SizedBox(
          width: 10,
        ),
        OBIconButton(
          OBIcons.filter,
          themeColor: OBIconThemeColor.primaryAccent,
          onPressed: _onWantsFilters,
        )
      ],
    );
  }

  void scrollToTop() {
    _timelinePostsController.scrollToTop();
  }

  void _onWantsFilters() {
    _modalService.openTimelineFilters(
        timelineController: widget.controller, context: context);
  }
}

class OBTimelinePageController extends PoppablePageController {
  OBTimelinePageState _state;

  void attach({@required BuildContext context, OBTimelinePageState state}) {
    super.attach(context: context);
    _state = state;
  }

  Future<void> setPostFilters(
      {List<Circle> circles, List<FollowsList> followsLists}) async {
    return _state._timelinePostsController
        .setFilters(circles: circles, followsLists: followsLists);
  }

  Future<void> clearPostFilters(
      {List<Circle> circles, List<FollowsList> followsLists}) async {
    return _state._timelinePostsController
        .setFilters(circles: circles, followsLists: followsLists);
  }

  List<Circle> getFilteredCircles() {
    return _state._timelinePostsController.getFilteredCircles();
  }

  List<FollowsList> getFilteredFollowsLists() {
    return _state._timelinePostsController.getFilteredFollowsLists();
  }

  void scrollToTop() {
    _state.scrollToTop();
  }
}
