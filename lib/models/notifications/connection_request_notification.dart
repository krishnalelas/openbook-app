import 'package:Openbook/models/user.dart';

class ConnectionRequestNotification {
  final int id;
  final User connectionRequester;

  ConnectionRequestNotification({this.id, this.connectionRequester});

  factory ConnectionRequestNotification.fromJson(Map<String, dynamic> json) {
    return ConnectionRequestNotification(
        id: json['id'],
        connectionRequester: _parseUser(json['connection_requester']));
  }

  static User _parseUser(Map userData) {
    return User.fromJson(userData);
  }
}
