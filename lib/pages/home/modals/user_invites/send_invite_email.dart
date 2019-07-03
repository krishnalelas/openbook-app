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

class OBSendUserInviteEmailModal extends StatefulWidget {
  final UserInvite userInvite;
  final bool autofocusEmailTextField;

  OBSendUserInviteEmailModal(
      {this.userInvite, this.autofocusEmailTextField = false});

  @override
  OBSendUserInviteEmailModalState createState() {
    return OBSendUserInviteEmailModalState();
  }
}

class OBSendUserInviteEmailModalState
    extends State<OBSendUserInviteEmailModal> {

  UserService _userService;
  ToastService _toastService;
  ValidationService _validationService;

  CancelableOperation _emailOperation;

  bool _requestInProgress;
  bool _formWasSubmitted;
  bool _formValid;

  GlobalKey<FormState> _formKey;

  TextEditingController _emailController;

  @override
  void dispose() {
    super.dispose();
    if (_emailOperation != null) _emailOperation.cancel();
  }

  @override
  void initState() {
    super.initState();
    _formValid = true;
    _requestInProgress = false;
    _formWasSubmitted = false;
    _emailController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    if (widget.userInvite.email != null) {
      _emailController.text = widget.userInvite.email;
    }

    _emailController.addListener(_updateFormValid);
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;
    _validationService = buzzingProvider.validationService;

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
                                autofocus: widget.autofocusEmailTextField,
                                controller: _emailController,
                                decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'e.g. janedoe@email.com'),
                                validator: (String email) {
                                  if (!_formWasSubmitted) return null;
                                  return _validationService.validateUserEmail(email);
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
        title: 'Email invite',
        trailing: OBButton(
          isDisabled: !_formValid,
          isLoading: _requestInProgress,
          size: OBButtonSize.small,
          onPressed: _submitForm,
          child: Text('Send'),
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
      _emailOperation = CancelableOperation.fromFuture(
          _userService.sendUserInviteEmail(
              widget.userInvite, _emailController.text)
      );
      await _emailOperation.value;
      _showUserInviteSent();
      Navigator.of(context).pop(widget.userInvite);
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
      _emailOperation = null;
    }
  }

  void _showUserInviteSent() {
    _toastService.success(message: 'Invite email sent', context: context);
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
