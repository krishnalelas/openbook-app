import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBDisableCommentsPostTile extends StatefulWidget {
  final Post post;
  final VoidCallback onDisableComments;
  final VoidCallback onEnableComments;

  const OBDisableCommentsPostTile({
    Key key,
    @required this.post,
    this.onDisableComments,
    this.onEnableComments,
  }) : super(key: key);

  @override
  OBDisableCommentsPostTileState createState() {
    return OBDisableCommentsPostTileState();
  }
}

class OBDisableCommentsPostTileState extends State<OBDisableCommentsPostTile> {
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
      stream: widget.post.updateSubject,
      initialData: widget.post,
      builder: (BuildContext context, AsyncSnapshot<Post> snapshot) {
        var post = snapshot.data;

        bool areCommentsEnabled = post.areCommentsEnabled;

        return ListTile(
          enabled: !_requestInProgress,
          leading: OBIcon(areCommentsEnabled ? OBIcons.disableComments : OBIcons.enableComments),
          title: OBText(areCommentsEnabled
              ? 'Disable post comments'
              : 'Enable post comments'),
          onTap: areCommentsEnabled ? _disableComments : _enableComments,
        );
      },
    );
  }

  void _enableComments() async {
    _setRequestInProgress(true);
    try {
      await _userService.enableCommentsForPost(widget.post);
      if (widget.onDisableComments != null) widget.onDisableComments();
      _toastService.success(message: 'Comments enabled for post', context: context);
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _disableComments() async {
    _setRequestInProgress(true);
    try {
      await _userService.disableCommentsForPost(widget.post);
      if (widget.onEnableComments != null) widget.onEnableComments();
      _toastService.success(message: 'Comments disabled for post', context: context);
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
