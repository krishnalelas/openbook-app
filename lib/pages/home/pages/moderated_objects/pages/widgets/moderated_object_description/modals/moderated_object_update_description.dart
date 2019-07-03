import 'package:Buzzing/models/moderation/moderated_object.dart';
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

class OBModeratedObjectUpdateDescriptionModal extends StatefulWidget {
  final ModeratedObject moderatedObject;

  const OBModeratedObjectUpdateDescriptionModal(
      {Key key, @required this.moderatedObject})
      : super(key: key);

  @override
  OBModeratedObjectUpdateDescriptionModalState createState() {
    return OBModeratedObjectUpdateDescriptionModalState();
  }
}

class OBModeratedObjectUpdateDescriptionModalState
    extends State<OBModeratedObjectUpdateDescriptionModal> {
  UserService _userService;
  ToastService _toastService;
  ValidationService _validationService;

  bool _requestInProgress;
  bool _formWasSubmitted;
  bool _formValid;

  GlobalKey<FormState> _formKey;

  TextEditingController _descriptionController;

  CancelableOperation _editDescriptionOperation;

  @override
  void initState() {
    super.initState();
    _formValid = true;
    _requestInProgress = false;
    _formWasSubmitted = false;
    _descriptionController =
        TextEditingController(text: widget.moderatedObject.description);
    _formKey = GlobalKey<FormState>();

    _descriptionController.addListener(_updateFormValid);
  }

  @override
  void dispose() {
    super.dispose();
    if (_editDescriptionOperation != null) _editDescriptionOperation.cancel();
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
                                autofocus: true,
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                    labelText: 'Report description',
                                    hintText:
                                        'e.g. The report item was found to...'),
                                validator: (String description) {
                                  if (!_formWasSubmitted) return null;
                                  return _validationService
                                      .validateModeratedObjectDescription(
                                          description);
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
        title: 'Edit description',
        trailing: OBButton(
          isDisabled: !_formValid,
          isLoading: _requestInProgress,
          size: OBButtonSize.small,
          onPressed: _submitForm,
          child: Text('Save'),
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
      _editDescriptionOperation = CancelableOperation.fromFuture(
          _userService.updateModeratedObject(widget.moderatedObject,
              description: _descriptionController.text));

      await _editDescriptionOperation.value;

      Navigator.of(context).pop(_descriptionController.text);
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
      _editDescriptionOperation = null;
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

  void _setFormValid(bool formValid) {
    setState(() {
      _formValid = formValid;
    });
  }
}
