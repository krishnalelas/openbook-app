import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/models/post_comment_list.dart';
import 'package:Buzzing/models/user.dart';
import 'package:dcache/dcache.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:Buzzing/models/updatable_model.dart';

class PostComment extends UpdatableModel<PostComment> {
  final int id;
  int creatorId;
  int repliesCount;
  DateTime created;
  String text;
  User commenter;
  PostComment parentComment;
  PostCommentList replies;
  Post post;
  bool isEdited;
  bool isReported;

  static convertPostCommentSortTypeToString(PostCommentsSortType type) {
    String result;
    switch (type) {
      case PostCommentsSortType.asc:
        result = 'ASC';
        break;
      case PostCommentsSortType.dec:
        result = 'DESC';
        break;
      default:
        throw 'Unsupported post comment sort type';
    }
    return result;
  }

  static PostCommentsSortType parsePostCommentSortType(String sortType) {
    PostCommentsSortType type;
    if (sortType == 'ASC') {
      type = PostCommentsSortType.asc;
    }

    if (sortType == 'DESC') {
      type = PostCommentsSortType.dec;
    }

    return type;
  }

  static void clearCache() {
    factory.clearCache();
  }

  PostComment({
    this.id,
    this.created,
    this.text,
    this.creatorId,
    this.commenter,
    this.post,
    this.isEdited,
    this.isReported,
    this.parentComment,
    this.replies,
    this.repliesCount,
  });

  static final factory = PostCommentFactory();

  factory PostComment.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('commenter')) {
      commenter = factory.parseUser(json['commenter']);
    }

    if (json.containsKey('creater_id')) {
      creatorId = json['creator_id'];
    }

    if (json.containsKey('replies_count')) {
      repliesCount = json['replies_count'];
    }

    if (json.containsKey('is_edited')) {
      isEdited = json['is_edited'];
    }

    if (json.containsKey('is_reported')) {
      isReported = json['is_reported'];
    }

    if (json.containsKey('text')) {
      text = json['text'];
    }

    if (json.containsKey('post')) {
      post = factory.parsePost(json['post']);
    }

    if (json.containsKey('created')) {
      created = factory.parseCreated(json['created']);
    }

    if (json.containsKey('parent_comment')) {
      parentComment = factory.parseParentComment(json['parent_comment']);
    }

    if (json.containsKey('replies')) {
      replies = factory.parseCommentReplies(json['replies']);
    }
  }

  String getRelativeCreated() {
    return timeago.format(created);
  }

  String getCommenterUsername() {
    return this.commenter.username;
  }

  String getCommenterName() {
    return this.commenter.getProfileName();
  }

  String getCommenterProfileAvatar() {
    return this.commenter.getProfileAvatar();
  }

  bool hasReplies() {
    return repliesCount != null && repliesCount > 0 && replies != null;
  }

  List<PostComment> getPostCommentReplies() {
    if (replies == null) return [];
    return replies.comments;
  }

  int getCommenterId() {
    return this.commenter.id;
  }

  int getPostCreatorId() {
    return post.getCreatorId();
  }

  void setIsReported(isReported) {
    this.isReported = isReported;
    notifyUpdate();
  }
}

class PostCommentFactory extends UpdatableModelFactory<PostComment> {
  @override
  SimpleCache<int, PostComment> cache =
      LruCache(storage: UpdatableModelSimpleStorage(size: 200));

  @override
  PostComment makeFromJson(Map json) {
    return PostComment(
        id: json['id'],
        creatorId: json['creator_id'],
        created: parseCreated(json['created']),
        commenter: parseUser(json['commenter']),
        post: parsePost(json['post']),
        repliesCount: json['replies_count'],
        replies: parseCommentReplies(json['replies']),
        parentComment: parseParentComment(json['parent_comment']),
        isEdited: json['is_edited'],
        isReported: json['is_reported'],
        text: json['text']);
  }

  Post parsePost(Map post) {
    if (post == null) return null;
    return Post.fromJson(post);
  }

  DateTime parseCreated(String created) {
    if (created == null) return null;
    return DateTime.parse(created).toLocal();
  }

  User parseUser(Map userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  PostComment parseParentComment(Map commentData) {
    if (commentData == null) return null;
    return PostComment.fromJSON(commentData);
  }

  PostCommentList parseCommentReplies(List<dynamic> repliesData) {
    if (repliesData == null) return null;
    return PostCommentList.fromJson(repliesData);
  }

}

enum PostCommentsSortType { asc, dec }
