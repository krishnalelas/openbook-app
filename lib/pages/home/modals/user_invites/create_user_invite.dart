import 'package:Buzzing/models/user_invite.dart';
import 'package:Buzzing/services/navigation_service.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/services/validation.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/fields/text_form_field.dart';
import 'package:Buzzing/widgets/page_scaffold.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCreateUserInviteModal extends StatefulWidget {
  final UserInvite userInvite;
  final bool autofocusNameTextField;

  OBCreateUserInviteModal(
      {this.userInvite, this.autofocusNameTextField = false});

  @override
  OBCreateUserInviteModalState createState() {
    return OBCreateUserInviteModalState();
  }
}

class OBCreateUserInviteModalState extends State<OBCreateUserInviteModal> {
  UserService _userService;
  ToastService _toastService;
  NavigationService _navigationService;
  ValidationService _validationService;

  bool _requestInProgress;
  bool _formWasSubmitted;
  bool _formValid;
  bool _hasExistingUserInvite;

  GlobalKey<FormState> _formKey;

  TextEditingController _nicknameController;

  CancelableOperation _createUpdateOperation;

  @override
  void initState() {
    super.initState();
    _formValid = true;
    _requestInProgress = false;
    _formWasSubmitted = false;
    _nicknameController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _hasExistingUserInvite = widget.userInvite != null;
    if (_hasExistingUserInvite) {
      _nicknameController.text = widget.userInvite.nickname;
    }

    _nicknameController.addListener(_updateFormValid);
  }

  @override
  void dispose() {
    super.dispose();
    if (_createUpdateOperation != null) _createUpdateOperation.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;
    _validationService = buzzingProvider.validationService;
    _navigationService = buzzingProvider.navigationService;

    return OBCupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: <Widget>[
                            OBTextFormField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                size: OBTextFormFieldSize.large,
                                autofocus: widget.autofocusNameTextField,
                                controller: _nicknameController,
                                decoration: InputDecoration(
                                    labelText: 'Nickname',
                                    hintText: 'e.g. Jane Doe'),
                                validator: (String userInviteNickname) {
                                  if (!_formWasSubmitted) return null;
                                  return _validationService
                                      .validateUserProfileName(
                                          userInviteNickname);
                                }),
                          ],
                        )),
                  ],
                )),
          ),
        ));
  }

  Widget _buildNavigationBar() {
    return OBThemedNavigationBar(
        leading: GestureDetector(
          child: const OBIcon(OBIcons.close),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: _hasExistingUserInvite ? 'Edit invite' : 'Create invite',
        trailing: OBButton(
          isDisabled: !_formValid,
          isLoading: _requestInProgress,
          size: OBButtonSize.small,
          onPressed: _submitForm,
          child: _hasExistingUserInvite ? Text('Save') : Text('Create'),
        ));
  }

  bool _validateForm() {
    return _formKey.currentState.validate();
  }

  bool _updateFormValid() {
    var formValid = _validateForm();
    _setFormValid(formValid);
    return formValid;
  }

  void _submitForm() async {
    _formWasSubmitted = true;

    var formIsValid = _updateFormValid();
    if (!formIsValid) return;
    _setRequestInProgress(true);
    try {
      _createUpdateOperation = CancelableOperation.fromFuture(
          _hasExistingUserInvite
              ? _userService.updateUserInvite(
                  userInvite: widget.userInvite,
                  nickname:
                      _nicknameController.text != widget.userInvite.nickname
                          ? _nicknameController.text
                          : null)
              : _userService.createUserInvite(
                  nickname: _nicknameController.text));

      UserInvite userInvite = await _createUpdateOperation.value;
      if (!_hasExistingUserInvite) {
        _navigateToShareInvite(userInvite);
      } else {
        Navigator.of(context).pop(userInvite);
      }
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
      _createUpdateOperation = null;
    }
  }

  void _navigateToShareInvite(UserInvite userInvite) async {
    Navigator.pop(context, userInvite);
    await _navigationService.navigateToShareInvite(
        context: context, userInvite: userInvite);
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

  void _setFormValid(bool formValid) {
    setState(() {
      _formValid = formValid;
    });
  }
}
