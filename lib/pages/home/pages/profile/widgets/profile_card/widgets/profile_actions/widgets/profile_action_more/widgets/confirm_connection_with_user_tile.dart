import 'package:Buzzing/models/circle.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/bottom_sheet.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBConfirmConnectionWithUserTile extends StatefulWidget {
  final User user;
  final VoidCallback onWillShowModalBottomSheet;

  const OBConfirmConnectionWithUserTile(this.user,
      {Key key, this.onWillShowModalBottomSheet})
      : super(key: key);

  @override
  OBConfirmConnectionWithUserTileState createState() {
    return OBConfirmConnectionWithUserTileState();
  }
}

class OBConfirmConnectionWithUserTileState
    extends State<OBConfirmConnectionWithUserTile> {
  UserService _userService;
  ToastService _toastService;
  BottomSheetService _bottomSheetService;

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;
    _bottomSheetService = buzzingProvider.bottomSheetService;

    String userName = widget.user.getProfileName();

    return ListTile(
        title: OBText('Confirm connection with $userName'),
        leading: const OBIcon(OBIcons.check),
        onTap: _displayAddConnectionToCirclesBottomSheet);
  }

  void _displayAddConnectionToCirclesBottomSheet() {
    if (widget.onWillShowModalBottomSheet != null)
      widget.onWillShowModalBottomSheet();
    _bottomSheetService.showConnectionsCirclesPicker(
        context: context,
        title: 'Add connection to circle',
        actionLabel: 'Confirm',
        onPickedCircles: _onWantsToAddConnectionToCircles);
  }

  Future _onWantsToAddConnectionToCircles(List<Circle> circles) async {
    await _confirmConnectionWithUser(circles);
  }

  Future _confirmConnectionWithUser(List<Circle> circles) async {
    try {
      await _userService.confirmConnectionWithUserWithUsername(
          widget.user.username,
          circles: circles);
      if (!widget.user.isFollowing) widget.user.incrementFollowersCount();
      _toastService.success(message: 'Connection confirmed', context: context);
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
