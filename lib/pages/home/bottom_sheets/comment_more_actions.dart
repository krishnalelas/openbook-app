import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/models/post_comment.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/modal_service.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBCommentMoreActionsBottomSheet extends StatefulWidget {
  final PostComment postComment;
  final Post post;

  const OBCommentMoreActionsBottomSheet({
    @required this.post,
    @required this.postComment,
    Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBCommentMoreActionsBottomSheetState();
  }
}

class OBCommentMoreActionsBottomSheetState extends State<OBCommentMoreActionsBottomSheet> {
  ToastService _toastService;
  UserService _userService;
  ModalService _modalService;
  bool _requestInProgress;

  @override
  void initState() {
    _requestInProgress = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BuzzingProviderState provider = BuzzingProvider.of(context);
    _toastService = provider.toastService;
    _userService = provider.userService;
    _modalService = provider.modalService;
    List<Widget> _moreCommentActions = [];

    User loggedInUser = _userService.getLoggedInUser();
    bool loggedInUserIsCommunityAdministrator = false;
    bool loggedInUserIsCommunityModerator = false;

    Post post = widget.post;
    User postCommenter = widget.postComment.commenter;

    _moreCommentActions.add(
      ListTile(
        leading: const OBIcon(OBIcons.editPost),
        title: const OBText(
          'Report comment',
        ),
        onTap: _reportPostComment,
      ),
    );


    return OBPrimaryColorContainer(
      mainAxisSize: MainAxisSize.min,
      child: Column(
        children: _moreCommentActions,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }

  void _reportPostComment() async {
    _toastService.error(message: 'Not implemented yet', context: context);
    Navigator.pop(context);
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
