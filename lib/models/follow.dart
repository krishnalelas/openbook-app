import 'package:Buzzing/models/follows_list.dart';
import 'package:Buzzing/models/user.dart';

class Follow {
  final int id;
  final FollowsList list;
  final User followedUser;

  Follow({this.id, this.list, this.followedUser});

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
        id: json['id'],
        followedUser: _parseFollowedUser(json['followed_user']));
  }

  static User _parseFollowedUser(Map followedUserData) {
    if (followedUserData == null) return null;
    return User.fromJson(followedUserData);
  }
}
