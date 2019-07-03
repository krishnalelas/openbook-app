import 'package:Buzzing/models/moderation/moderated_object.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/checkbox.dart';
import 'package:Buzzing/widgets/moderated_object_status_circle.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/page_scaffold.dart';
import 'package:Buzzing/widgets/progress_indicator.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBModeratedObjectUpdateStatusModal extends StatefulWidget {
  final ModeratedObject moderatedObject;

  const OBModeratedObjectUpdateStatusModal(
      {Key key, @required this.moderatedObject})
      : super(key: key);

  @override
  OBModeratedObjectUpdateStatusModalState createState() {
    return OBModeratedObjectUpdateStatusModalState();
  }
}

class OBModeratedObjectUpdateStatusModalState
    extends State<OBModeratedObjectUpdateStatusModal> {
  UserService _userService;
  ToastService _toastService;
  List<ModeratedObjectStatus> _moderationStatuses = [
    ModeratedObjectStatus.rejected,
    ModeratedObjectStatus.approved,
  ];
  ModeratedObjectStatus _selectedModerationStatus;
  bool _needsBootstrap;
  bool _requestInProgress;

  CancelableOperation _updateStatusOperation;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _requestInProgress = false;
    _selectedModerationStatus = widget.moderatedObject.status;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var buzzingProvider = BuzzingProvider.of(context);
      _toastService = buzzingProvider.toastService;
      _userService = buzzingProvider.userService;
      _needsBootstrap = false;
    }

    return OBCupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _moderationStatuses.isEmpty
                  ? _buildProgressIndicator()
                  : _buildModerationStatuses(),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    if (_updateStatusOperation != null) _updateStatusOperation.cancel();
  }

  Widget _buildProgressIndicator() {
    return Expanded(
      child: Center(
        child: OBProgressIndicator(),
      ),
    );
  }

  Widget _buildModerationStatuses() {
    return Expanded(
      child: ListView.separated(
        itemBuilder: _buildModerationStatusTile,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemCount: _moderationStatuses.length,
      ),
    );
  }

  Widget _buildModerationStatusTile(context, index) {
    ModeratedObjectStatus status = _moderationStatuses[index];
    String statusString = ModeratedObject.factory
        .convertStatusToHumanReadableString(status, capitalize: true);

    return GestureDetector(
      key: Key(statusString),
      onTap: () => _setSelectedModerationStatus(status),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              title: Row(
                children: <Widget>[
                  OBModeratedObjectStatusCircle(
                    status: status,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  OBText(
                    statusString,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              //trailing: OBIcon(OBIcons.chevronRight),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: OBCheckbox(
              value: _selectedModerationStatus == status,
            ),
          )
        ],
      ),
    );
  }

  void _setSelectedModerationStatus(ModeratedObjectStatus status) {
    setState(() {
      _selectedModerationStatus = status;
    });
  }

  void _saveModerationStatus() async {
    _setRequestInProgress(true);
    try {
      if (_selectedModerationStatus == widget.moderatedObject.status) {
        Navigator.of(context).pop();
        return;
      }

      switch (_selectedModerationStatus) {
        case ModeratedObjectStatus.approved:
          _updateStatusOperation = CancelableOperation.fromFuture(
              _userService.approveModeratedObject(widget.moderatedObject));
          break;
        case ModeratedObjectStatus.rejected:
          _updateStatusOperation = CancelableOperation.fromFuture(
              _userService.rejectModeratedObject(widget.moderatedObject));
          break;
        default:
          throw 'Unsuppported update type';
      }
      await _updateStatusOperation.value;
      Navigator.of(context).pop(_selectedModerationStatus);
      widget.moderatedObject.setStatus(_selectedModerationStatus);
    } catch (error) {
      _onError(error);
    } finally {
      _updateStatusOperation = null;
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

  Widget _buildNavigationBar() {
    return OBThemedNavigationBar(
      title: 'Update status',
      trailing: OBButton(
        isLoading: _requestInProgress,
        size: OBButtonSize.small,
        onPressed: _saveModerationStatus,
        child: Text('Save'),
      ),
    );
  }

  _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}

typedef OnObjectReported(dynamic object);
