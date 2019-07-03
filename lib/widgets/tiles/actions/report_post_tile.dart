import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/navigation_service.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBReportPostTile extends StatefulWidget {
  final Post post;
  final ValueChanged<Post> onPostReported;
  final VoidCallback onWantsToReportPost;

  const OBReportPostTile({
    Key key,
    this.onPostReported,
    @required this.post,
    this.onWantsToReportPost,
  }) : super(key: key);

  @override
  OBReportPostTileState createState() {
    return OBReportPostTileState();
  }
}

class OBReportPostTileState extends State<OBReportPostTile> {
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
      stream: widget.post.updateSubject,
      initialData: widget.post,
      builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
        var post = snapshot.data;

        bool isReported = post.isReported ?? false;

        return OBLoadingTile(
          isLoading: _requestInProgress || isReported,
          leading: OBIcon(OBIcons.report),
          title: OBText(
              isReported ? 'You have reported this post' : 'Report post'),
          onTap: isReported ? () {} : _reportPost,
        );
      },
    );
  }

  void _reportPost() {
    if (widget.onWantsToReportPost != null) widget.onWantsToReportPost();
    _navigationService.navigateToReportObject(
        context: context,
        object: widget.post,
        onObjectReported: (dynamic reportedObject) {
          if (reportedObject != null && widget.onPostReported != null)
            widget.onPostReported(reportedObject as Post);
        });
  }
}
