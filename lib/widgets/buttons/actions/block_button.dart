import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
export 'package:Buzzing/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class OBBlockButton extends StatefulWidget {
  final User user;
  final OBButtonSize size;

  OBBlockButton(this.user,
      {this.size = OBButtonSize.medium});

  @override
  OBBlockButtonState createState() {
    return OBBlockButtonState();
  }
}

class OBBlockButtonState extends State<OBBlockButton> {
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

        return isBlocked ? _buildUnblockButton() : _buildBlockButton();
      },
    );
  }

  Widget _buildBlockButton() {
    return OBButton(
      size: widget.size,
      child: Text(
        'Block',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      isLoading: _requestInProgress,
      onPressed: _blockUser,
    );
  }

  Widget _buildUnblockButton() {
    return OBButton(
      size: widget.size,
      child: Text(
        'Unblock',
      ),
      isLoading: _requestInProgress,
      onPressed: _unBlockUser,
      type: OBButtonType.danger,
    );
  }

  void _blockUser() async {
    _setRequestInProgress(true);
    try {
      await _userService.blockUser(widget.user);
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _unBlockUser() async {
    _setRequestInProgress(true);
    try {
      await _userService.unblockUser(widget.user);
    } catch (error) {
      _onError(error);
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
