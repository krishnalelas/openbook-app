import 'package:Buzzing/models/circle.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/bottom_sheet.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:flutter/material.dart';

class OBConfirmConnectionButton extends StatefulWidget {
  final User user;

  OBConfirmConnectionButton(this.user);

  @override
  OBConfirmConnectionButtonState createState() {
    return OBConfirmConnectionButtonState();
  }
}

class OBConfirmConnectionButtonState extends State<OBConfirmConnectionButton> {
  UserService _userService;
  ToastService _toastService;
  BottomSheetService _bottomSheetService;
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
    _bottomSheetService = buzzingProvider.bottomSheetService;

    return StreamBuilder(
      stream: widget.user.updateSubject,
      initialData: widget.user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data;

        if (user?.isPendingConnectionConfirmation == null || !user.isConnected)
          return const SizedBox();

        return user.isPendingConnectionConfirmation
            ? _buildConfirmConnectionButton()
            : _buildDisconnectButton();
      },
    );
  }

  Widget _buildConfirmConnectionButton() {
    return OBButton(
      child: Text(
        'Confirm',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      isLoading: _requestInProgress,
      onPressed: _onWantsToConnectWithUser,
      type: OBButtonType.success,
    );
  }

  Widget _buildDisconnectButton() {
    return OBButton(
      child: Text(
        'Disconnect',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      isLoading: _requestInProgress,
      onPressed: _disconnectFromUser,
      type: OBButtonType.danger,
    );
  }

  void _onWantsToConnectWithUser() {
    _bottomSheetService.showConnectionsCirclesPicker(
        context: context,
        title: 'Confirm connection',
        actionLabel: 'Connect',
        onPickedCircles: _confirmConnectionWithUser);
  }

  Future _confirmConnectionWithUser(List<Circle> circles) async {
    if (_requestInProgress) return;
    _setRequestInProgress(true);
    try {
      await _userService.confirmConnectionWithUserWithUsername(
          widget.user.username,
          circles: circles);
      if (!widget.user.isFollowing) widget.user.incrementFollowersCount();
      _toastService.success(message: 'Connection confirmed', context: context);
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

  Future _disconnectFromUser() async {
    if (_requestInProgress) return;
    _setRequestInProgress(true);
    try {
      await _userService.disconnectFromUserWithUsername(widget.user.username);
      widget.user.decrementFollowersCount();
      _toastService.success(
          message: 'Disconnected successfully', context: context);
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
