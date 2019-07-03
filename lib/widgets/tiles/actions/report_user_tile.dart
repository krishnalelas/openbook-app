import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/navigation_service.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBReportUserTile extends StatefulWidget {
  final User user;
  final ValueChanged<dynamic> onUserReported;
  final VoidCallback onWantsToReportUser;

  const OBReportUserTile({
    Key key,
    this.onUserReported,
    @required this.user,
    this.onWantsToReportUser,
  }) : super(key: key);

  @override
  OBReportUserTileState createState() {
    return OBReportUserTileState();
  }
}

class OBReportUserTileState extends State<OBReportUserTile> {
  NavigationService _navigationService;
  bool _requestInProgress;

  @override
  void initState() {
    super.initState();
    _requestInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _navigationService = buzzingProvider.navigationService;

    return StreamBuilder(
      stream: widget.user.updateSubject,
      initialData: widget.user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var user = snapshot.data;

        bool isReported = user.isReported ?? false;

        return OBLoadingTile(
          isLoading: _requestInProgress || isReported,
          leading: OBIcon(OBIcons.report),
          title: OBText(
              isReported ? 'You have reported this account' : 'Report account'),
          onTap: isReported ? () {} : _reportUser,
        );
      },
    );
  }

  void _reportUser() {
    if (widget.onWantsToReportUser != null) widget.onWantsToReportUser();
    _navigationService.navigateToReportObject(
        context: context,
        object: widget.user,
        onObjectReported: widget.onUserReported);
  }
}
