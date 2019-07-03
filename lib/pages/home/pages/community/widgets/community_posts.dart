import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/models/posts_list.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/http_list.dart';
import 'package:Buzzing/widgets/post/post.dart';
import 'package:flutter/material.dart';

class OBCommunityPosts extends StatefulWidget {
  final Community community;
  final List<Widget> prependedItems;
  final OBHttpListController httpListController;
  final OBHttpListSecondaryRefresher httpListSecondaryRefresher;

  const OBCommunityPosts(
      {Key key,
      @required this.community,
      this.prependedItems,
      this.httpListController,
      this.httpListSecondaryRefresher})
      : super(key: key);

  @override
  OBCommunityPostsState createState() {
    return OBCommunityPostsState();
  }
}

class OBCommunityPostsState extends State<OBCommunityPosts> {
  UserService _userService;

  OBHttpListController _httpListController;
  bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _httpListController = widget.httpListController ?? OBHttpListController();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var provider = BuzzingProvider.of(context);
      _userService = provider.userService;
      _needsBootstrap = false;
    }

    return OBHttpList<Post>(
      controller: _httpListController,
      listItemBuilder: _buildCommunityPostListItem,
      searchResultListItemBuilder: _buildCommunityPostListItem,
      listRefresher: _refreshCommunityPosts,
      listOnScrollLoader: _loadMoreCommunityPosts,
      secondaryRefresher: widget.httpListSecondaryRefresher,
      prependedItems: widget.prependedItems,
      resourceSingularName: 'post',
      resourcePluralName: 'posts',
    );
  }

  Widget _buildCommunityPostListItem(BuildContext context, Post post) {
    return StreamBuilder(
        stream: post.updateSubject,
        initialData: post,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          Post post = snapshot.data;
          return OBPost(post,
              onTextExpandedChange: _onTextExpandedChange,
              onPostDeleted: _onPostDeleted,
              key: Key(post.id.toString()));
        });
  }

  void _onPostDeleted(Post post) {
    _httpListController.removeListItem(post);
  }

  void _onTextExpandedChange({@required Post post, @required bool isExpanded}) {
    print(isExpanded);
  }

  Future<List<Post>> _refreshCommunityPosts() async {
    debugPrint('Refreshing community posts');
    PostsList communityPosts =
        await _userService.getPostsForCommunity(widget.community);
    return communityPosts.posts;
  }

  Future<List<Post>> _loadMoreCommunityPosts(
      List<Post> communityPostsList) async {
    debugPrint('Loading more community posts');
    var lastCommunityPost = communityPostsList.last;
    var lastCommunityPostId = lastCommunityPost.id;
    var moreCommunityPosts = (await _userService.getPostsForCommunity(
      widget.community,
      maxId: lastCommunityPostId,
      count: 20,
    ))
        .posts;
    return moreCommunityPosts;
  }
}
