import 'package:Buzzing/models/emoji.dart';
import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostReaction {
  final int id;
  final DateTime created;
  final Emoji emoji;
  final User reactor;
  final Post post;

  PostReaction({this.id, this.created, this.emoji, this.reactor, this.post});

  factory PostReaction.fromJson(Map<String, dynamic> parsedJson) {
    DateTime created;
    var createdData = parsedJson['created'];
    if (createdData != null) created = DateTime.parse(createdData).toLocal();

    User reactor;
    var reactorData = parsedJson['reactor'];
    if (reactorData != null) reactor = User.fromJson(reactorData);

    Post post;
    if (parsedJson.containsKey('post')) {
      post = Post.fromJson(parsedJson['post']);
    }

    Emoji emoji = Emoji.fromJson(parsedJson['emoji']);

    return PostReaction(
        id: parsedJson['id'],
        created: created,
        reactor: reactor,
        emoji: emoji,
        post: post);
  }

  String getRelativeCreated() {
    return timeago.format(created);
  }

  String getReactorUsername() {
    return this.reactor.username;
  }

  String getReactorProfileAvatar() {
    return this.reactor.getProfileAvatar();
  }

  int getReactorId() {
    return this.reactor.id;
  }

  int getEmojiId() {
    return this.emoji.id;
  }

  String getEmojiImage() {
    return this.emoji.image;
  }

  String getEmojiKeyword() {
    return this.emoji.keyword;
  }

  String getEmojiColor() {
    return this.emoji.color;
  }

  PostReaction copy({Emoji newEmoji}) {
    return PostReaction(emoji: newEmoji ?? emoji);
  }
}
