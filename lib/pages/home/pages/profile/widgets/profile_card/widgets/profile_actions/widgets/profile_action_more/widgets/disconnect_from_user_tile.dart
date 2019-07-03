import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBDisconnectFromUserTile extends StatefulWidget {
  final User user;
  final String title;
  final VoidCallback onDisconnectedFromUser;

  const OBDisconnectFromUserTile(this.user,
      {Key key, this.title, @required this.onDisconnectedFromUser})
      : super(key: key);

  @override
  OBDisconnectFromUserTileState createState() {
    return OBDisconnectFromUserTileState();
  }
}

class OBDisconnectFromUserTileState extends State<OBDisconnectFromUserTile> {
  UserService _userService;
  ToastService _toastService;

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;

    String userName = widget.user.getProfileName();

    return ListTile(
        title: OBText(widget.title ?? 'Disconnect from $userName'),
        leading: const OBIcon(OBIcons.disconnect),
        onTap: () async {
          await _disconnectFromUser();
          widget.onDisconnectedFromUser();
        });
  }

  Future _disconnectFromUser() async {
    try {
      await _userService.disconnectFromUserWithUsername(widget.user.username);
      widget.user.decrementFollowersCount();
      _toastService.success(
          message: 'Disconnected successfully', context: context);
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
