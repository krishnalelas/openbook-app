import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/pages/home/pages/profile/widgets/profile_card/profile_card.dart';
import 'package:Buzzing/pages/home/pages/profile/widgets/profile_cover.dart';
import 'package:Buzzing/pages/home/pages/profile/widgets/profile_nav_bar.dart';
import 'package:Buzzing/pages/home/pages/profile/widgets/profile_no_posts.dart';
import 'package:Buzzing/widgets/loadmore/loadmore_delegate.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/post/post.dart';
import 'package:Buzzing/widgets/progress_indicator.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Buzzing/widgets/load_more.dart';

class OBProfilePage extends StatefulWidget {
  final OBProfilePageController controller;
  final User user;

  OBProfilePage(
    this.user, {
    this.controller,
  });

  @override
  OBProfilePageState createState() {
    return OBProfilePageState();
  }
}

class OBProfilePageState extends State<OBProfilePage> {
  User _user;
  bool _needsBootstrap;
  bool _morePostsToLoad;
  List<Post> _posts;
  UserService _userService;
  ToastService _toastService;
  ScrollController _scrollController;
  bool _refreshPostsInProgress;

  CancelableOperation _loadMoreOperation;
  CancelableOperation _refreshUserOperation;
  CancelableOperation _refreshPostsOperation;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _needsBootstrap = true;
    _morePostsToLoad = false;
    _user = widget.user;
    _posts = [];
    _refreshPostsInProgress = false;
    if (widget.controller != null) widget.controller.attach(this);
  }

  @override
  void dispose() {
    super.dispose();
    if (_loadMoreOperation != null) _loadMoreOperation.cancel();
    if (_refreshUserOperation != null) _refreshUserOperation.cancel();
    if (_refreshPostsOperation != null) _refreshPostsOperation.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;

    if (_needsBootstrap) {
      _bootstrap();
      _needsBootstrap = false;
    }

    return CupertinoPageScaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        navigationBar: OBProfileNavBar(_user),
        child: OBPrimaryColorContainer(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    child: LoadMore(
                        whenEmptyLoad: false,
                        isFinish: !_morePostsToLoad,
                        delegate: OBHomePostsLoadMoreDelegate(),
                        child: ListView.builder(
                            controller: _scrollController,
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.all(0),
                            itemCount: _posts.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                Widget postsItem;

                                if (_refreshPostsInProgress && _posts.isEmpty) {
                                  postsItem = SizedBox(
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 20),
                                        child: OBProgressIndicator(),
                                      ),
                                    ),
                                  );
                                } else if (_posts.length == 0) {
                                  postsItem = OBProfileNoPosts(
                                    _user,
                                    onWantsToRefreshProfile: _refresh,
                                  );
                                } else {
                                  postsItem = const SizedBox(
                                    height: 20,
                                  );
                                }

                                return Column(
                                  children: <Widget>[
                                    OBProfileCover(_user),
                                    OBProfileCard(
                                      _user,
                                    ),
                                    postsItem
                                  ],
                                );
                              }

                              int postIndex = index - 1;

                              var post = _posts[postIndex];

                              return OBPost(post,
                                  onPostDeleted: _onPostDeleted,
                                  key: Key(post.id.toString()));
                            }),
                        onLoadMore: _loadMorePosts),
                    onRefresh: _refresh),
              )
            ],
          ),
        ));
  }

  void scrollToTop() {
    if (_scrollController.offset == 0) {
      _refreshIndicatorKey.currentState.show();
    }

    _scrollController.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _bootstrap() async {
    await _refresh();
  }

  Future<void> _refresh() async {
    try {
      await Future.wait([_refreshUser(), _refreshPosts()]);
    } catch (error) {
      _onError(error);
    }
  }

  Future<void> _refreshUser() async {
    if (_refreshUserOperation != null) _refreshUserOperation.cancel();
    try {
      _refreshUserOperation = CancelableOperation.fromFuture(
          _userService.getUserWithUsername(_user.username));
      var user = await _refreshUserOperation.value;
      _setUser(user);
    } catch (error) {
      _onError(error);
    } finally {
      _refreshUserOperation = null;
    }
  }

  Future<void> _refreshPosts() async {
    if (_refreshPostsOperation != null) _refreshPostsOperation.cancel();
    _setRefreshPostsInProgress(true);

    try {
      _refreshPostsOperation = CancelableOperation.fromFuture(
          _userService.getTimelinePosts(username: _user.username));
      _posts = (await _refreshPostsOperation.value).posts;
      _setPosts(_posts);
      _setMorePostsToLoad(true);
    } catch (error) {
      _onError(error);
    } finally {
      _setRefreshPostsInProgress(false);
      _refreshPostsOperation = null;
    }
  }

  Future<bool> _loadMorePosts() async {
    if (_loadMoreOperation != null) _loadMoreOperation.cancel();

    var lastPostId;
    if (_posts.isNotEmpty) {
      Post lastPost = _posts.last;
      lastPostId = lastPost.id;
    }

    try {
      _loadMoreOperation = CancelableOperation.fromFuture(_userService
          .getTimelinePosts(maxId: lastPostId, username: _user.username));

      var morePosts = (await _loadMoreOperation.value).posts;

      if (morePosts.length == 0) {
        _setMorePostsToLoad(false);
      } else {
        setState(() {
          _posts.addAll(morePosts);
        });
      }
      return true;
    } catch (error) {
      _onError(error);
    } finally {
      _loadMoreOperation = null;
    }

    return false;
  }

  void _onPostDeleted(Post deletedPost) {
    setState(() {
      _posts.remove(deletedPost);
    });
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

  void _setUser(User user) {
    setState(() {
      _user = user;
    });
  }

  void _setPosts(List<Post> posts) {
    setState(() {
      _posts = posts;
    });
  }

  void _setMorePostsToLoad(bool morePostsToLoad) {
    setState(() {
      _morePostsToLoad = morePostsToLoad;
    });
  }

  void _setRefreshPostsInProgress(bool refreshPostsInProgress) {
    setState(() {
      _refreshPostsInProgress = refreshPostsInProgress;
    });
  }
}

class OBProfilePageController {
  OBProfilePageState _timelinePageState;

  void attach(OBProfilePageState profilePageState) {
    assert(profilePageState != null, 'Cannot attach to empty state');
    _timelinePageState = profilePageState;
  }

  void scrollToTop() {
    if (_timelinePageState != null) _timelinePageState.scrollToTop();
  }
}

typedef void OnWantsToEditUserProfile(User user);
