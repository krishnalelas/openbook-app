import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBMutePostTile extends StatefulWidget {
  final Post post;
  final VoidCallback onMutedPost;
  final VoidCallback onUnmutedPost;

  const OBMutePostTile({
    Key key,
    @required this.post,
    this.onMutedPost,
    this.onUnmutedPost,
  }) : super(key: key);

  @override
  OBMutePostTileState createState() {
    return OBMutePostTileState();
  }
}

class OBMutePostTileState extends State<OBMutePostTile> {
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

        bool isMuted = post.isMuted;

        return OBLoadingTile(
          isLoading: _requestInProgress,
          leading: OBIcon(isMuted ? OBIcons.unmutePost : OBIcons.mutePost),
          title: OBText(isMuted
              ? 'Turn on post notifications'
              : 'Turn off post notifications'),
          onTap: isMuted ? _unmutePost : _mutePost,
        );
      },
    );
  }

  void _mutePost() async {
    _setRequestInProgress(true);
    try {
      await _userService.mutePost(widget.post);
      if (widget.onMutedPost != null) widget.onMutedPost();
    } catch (e) {
      _onError(e);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _unmutePost() async {
    _setRequestInProgress(true);
    try {
      await _userService.unmutePost(widget.post);
      if (widget.onUnmutedPost != null) widget.onUnmutedPost();
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
