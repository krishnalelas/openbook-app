import 'package:Buzzing/libs/pretty_count.dart';
import 'package:Buzzing/models/circle.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/navigation_service.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/circle_color_preview.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';
import 'package:flutter/material.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class OBConnectionsCircleTile extends StatefulWidget {
  final Circle connectionsCircle;
  final VoidCallback onConnectionsCircleDeletedCallback;
  final bool isReadOnly;

  OBConnectionsCircleTile(
      {@required this.connectionsCircle,
      Key key,
      this.onConnectionsCircleDeletedCallback,
      this.isReadOnly = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBConnectionsCircleTileState();
  }
}

class OBConnectionsCircleTileState extends State<OBConnectionsCircleTile> {
  bool _requestInProgress;
  UserService _userService;
  ToastService _toastService;
  NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var provider = BuzzingProvider.of(context);
    _userService = provider.userService;
    _toastService = provider.toastService;
    _navigationService = provider.navigationService;

    Widget tile = _buildTile();

    if (widget.isReadOnly) return tile;

    tile = Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: tile,
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: _deleteConnectionsCircle),
      ],
    );

    if (_requestInProgress) {
      tile = Opacity(opacity: 0.5, child: tile);
    }
    return tile;
  }

  Widget _buildTile() {
    String prettyCount = getPrettyCount(widget.connectionsCircle.usersCount);

    return ListTile(
        onTap: () {
          _navigationService.navigateToConnectionsCircle(
              connectionsCircle: widget.connectionsCircle, context: context);
        },
        leading: OBCircleColorPreview(
          widget.connectionsCircle,
          size: OBCircleColorPreviewSize.medium,
        ),
        title: OBText(
          widget.connectionsCircle.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: OBSecondaryText(prettyCount + ' people'));
  }

  void _deleteConnectionsCircle() async {
    _setRequestInProgress(true);
    try {
      await _userService.deleteConnectionsCircle(widget.connectionsCircle);
      // widget.post.decreaseCommentsCount();
      _setRequestInProgress(false);
      if (widget.onConnectionsCircleDeletedCallback != null) {
        widget.onConnectionsCircleDeletedCallback();
      }
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
