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

class OBUpdateConnectionWithUserTile extends StatefulWidget {
  final User user;
  final VoidCallback onWillShowModalBottomSheet;

  const OBUpdateConnectionWithUserTile(this.user,
      {Key key, @required this.onWillShowModalBottomSheet})
      : super(key: key);

  @override
  OBUpdateConnectionWithUserTileState createState() {
    return OBUpdateConnectionWithUserTileState();
  }
}

class OBUpdateConnectionWithUserTileState
    extends State<OBUpdateConnectionWithUserTile> {
  UserService _userService;
  ToastService _toastService;
  BottomSheetService _bottomSheetService;

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;
    _bottomSheetService = buzzingProvider.bottomSheetService;

    return ListTile(
        title: const OBText('Update connection circles'),
        leading: const OBIcon(OBIcons.circles),
        onTap: _displayAddConnectionToCirclesBottomSheet);
  }

  void _displayAddConnectionToCirclesBottomSheet() {
    if (widget.onWillShowModalBottomSheet != null)
      widget.onWillShowModalBottomSheet();

    List<Circle> connectedCircles = widget.user.connectedCircles.circles;

    _bottomSheetService.showConnectionsCirclesPicker(
        context: context,
        title: 'Update connection circles',
        actionLabel: 'Save',
        initialPickedCircles: connectedCircles,
        onPickedCircles: _onWantsToUpdateConnectionCircles);
  }

  Future _onWantsToUpdateConnectionCircles(List<Circle> circles) async {
    await _updateConnectionWithUser(circles);
  }

  Future _updateConnectionWithUser(List<Circle> circles) async {
    try {
      await _userService.updateConnectionWithUsername(widget.user.username,
          circles: circles);
      if (!widget.user.isFollowing) widget.user.incrementFollowersCount();
      _toastService.success(message: 'Connection updated', context: context);
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
