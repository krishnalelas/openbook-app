import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBRemoveAccountFromLists extends StatefulWidget {
  final User user;
  final VoidCallback onRemovedAccountFromLists;

  const OBRemoveAccountFromLists(this.user,
      {Key key, this.onRemovedAccountFromLists})
      : super(key: key);

  @override
  OBRemoveAccountFromListsState createState() {
    return OBRemoveAccountFromListsState();
  }
}

class OBRemoveAccountFromListsState extends State<OBRemoveAccountFromLists> {
  UserService _userService;
  ToastService _toastService;

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;

    return ListTile(
        title: const OBText('Remove account from lists'),
        leading: const OBIcon(OBIcons.removeFromList),
        onTap: _removeAccountFromLists);
  }

  Future _removeAccountFromLists() async {
    try {
      await _userService
          .updateFollowWithUsername(widget.user.username, followsLists: []);
      _toastService.success(message: 'Success', context: context);
      if (widget.onRemovedAccountFromLists != null)
        widget.onRemovedAccountFromLists();
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
