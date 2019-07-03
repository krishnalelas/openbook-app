import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';

class OBConfirmAddCommunityAdministrator<T> extends StatefulWidget {
  final User user;
  final Community community;

  const OBConfirmAddCommunityAdministrator(
      {Key key, @required this.user, @required this.community})
      : super(key: key);

  @override
  OBConfirmAddCommunityAdministratorState createState() {
    return OBConfirmAddCommunityAdministratorState();
  }
}

class OBConfirmAddCommunityAdministratorState
    extends State<OBConfirmAddCommunityAdministrator> {
  bool _confirmationInProgress;
  UserService _userService;
  ToastService _toastService;
  bool _needsBootstrap;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
    _confirmationInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    String username = widget.user.username;

    if (_needsBootstrap) {
      BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);
      _userService = buzzingProvider.userService;
      _toastService = buzzingProvider.toastService;
      _needsBootstrap = false;
    }

    return CupertinoPageScaffold(
        navigationBar: OBThemedNavigationBar(title: 'Confirmation'),
        child: OBPrimaryColorContainer(
            child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 40
                ),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    OBIcon(OBIcons.communityAdministrators, themeColor: OBIconThemeColor.primaryAccent, size: OBIconSize.extraLarge,),
                    const SizedBox(
                      height: 20,
                    ),
                    OBText(
                      'Are you sure you want to add @$username as a community administrator?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const OBText(
                        'This will allow the member to edit the community details, administrators, moderators and banned users.')
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OBButton(
                      size: OBButtonSize.large,
                      type: OBButtonType.highlight,
                      child: Text('No'),
                      onPressed: _onCancel,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: OBButton(
                      size: OBButtonSize.large,
                      child: Text('Yes'),
                      onPressed: _onConfirm,
                      isLoading: _confirmationInProgress,
                    ),
                  )
                ],
              ),
            )
          ],
        )));
  }

  void _onConfirm() async {
    _setConfirmationInProgress(true);
    try {
      await _userService.addCommunityAdministrator(
          community: widget.community, user: widget.user);
      Navigator.of(context).pop(true);
    } catch (error) {
      _onError(error);
    } finally {
      _setConfirmationInProgress(false);
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

  void _onCancel() {
    Navigator.of(context).pop(false);
  }

  void _setConfirmationInProgress(confirmationInProgress) {
    setState(() {
      _confirmationInProgress = confirmationInProgress;
    });
  }
}
