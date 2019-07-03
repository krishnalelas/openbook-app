import 'package:Buzzing/models/post_comment.dart';
import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/widgets/theming/actionable_smart_text.dart';
import 'package:Buzzing/widgets/theming/collapsible_smart_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OBPostCommentText extends StatelessWidget {
  final PostComment postComment;
  final VoidCallback onUsernamePressed;
  final Widget badge;
  ToastService _toastService;
  BuildContext _context;

  static int postCommentMaxVisibleLength = 500;

  OBPostCommentText(this.postComment,
      {Key key, this.onUsernamePressed, this.badge})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    var themeService = buzzingProvider.themeService;
    var themeValueParserService = buzzingProvider.themeValueParserService;

    _toastService = buzzingProvider.toastService;
    _context = context;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: GestureDetector(
                        onTap: onUsernamePressed,
                        child: Text(
                          postComment.getCommenterUsername(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: themeValueParserService
                                  .parseColor(theme.primaryTextColor),
                              fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        )),
                  ),
                  badge == null
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: badge,
                        ),
                ],
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: GestureDetector(
                      onLongPress: _copyText,
                      child: _getActionableSmartText(postComment.isEdited),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }

  Widget _getActionableSmartText(bool isEdited) {
    if (isEdited) {
      return OBCollapsibleSmartText(
        text: postComment.text,
        trailingSmartTextElement: SecondaryTextElement(' (edited)'),
        maxlength: postCommentMaxVisibleLength,
      );
    } else {
      return OBCollapsibleSmartText(
        text: postComment.text,
        maxlength: postCommentMaxVisibleLength,
      );
    }
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: postComment.text));
    _toastService.toast(
        message: 'Text copied!', context: _context, type: ToastType.info);
  }
}
