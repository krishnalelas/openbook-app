import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBBlockUserTile extends StatefulWidget {
  final User user;
  final VoidCallback onBlockedUser;
  final VoidCallback onUnblockedUser;

  const OBBlockUserTile({
    Key key,
    @required this.user,
    this.onBlockedUser,
    this.onUnblockedUser,
  }) : super(key: key);

  @override
  OBBlockUserTileState createState() {
    return OBBlockUserTileState();
  }
}

class OBBlockUserTileState extends State<OBBlockUserTile> {
  UserService _userService;
  ToastService _toastService;
  bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;

    return StreamBuilder(
      stream: widget.user.updateSubject,
      initialData: widget.user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data;

        bool isBlocked = user.isBlocked ?? false;

        return OBLoadingTile(
          isLoading: _requestInProgress,
          leading: OBIcon(isBlocked ? OBIcons.block : OBIcons.block),
          title: OBText(isBlocked
              ? 'Unblock user'
              : 'Block user'),
          onTap: isBlocked ? _unblockUser : _blockUser,
        );
      },
    );
  }

  void _blockUser() async {
    _setRequestInProgress(true);
    try {
      await _userService.blockUser(widget.user);
      if (widget.onBlockedUser != null) widget.onBlockedUser();
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _unblockUser() async {
    _setRequestInProgress(true);
    try {
      await _userService.unblockUser(widget.user);
      if (widget.onUnblockedUser != null) widget.onUnblockedUser();
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
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

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
