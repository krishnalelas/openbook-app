import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/navigation_service.dart';
import 'package:Buzzing/services/validation.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/fields/text_form_field.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/widgets/page_scaffold.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBDeleteAccountPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBDeleteAccountPageState();
  }
}

class OBDeleteAccountPageState extends State<OBDeleteAccountPage> {
  ValidationService _validationService;
  NavigationService _navigationService;

  static const double INPUT_ICONS_SIZE = 16;
  static const EdgeInsetsGeometry INPUT_CONTENT_PADDING =
      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _formWasSubmitted = false;
  bool _formValid = true;
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formWasSubmitted = false;
    _formValid = true;
    _currentPasswordController.addListener(_updateFormValid);
    _newPasswordController.addListener(_updateFormValid);
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _validationService = buzzingProvider.validationService;
    _navigationService = buzzingProvider.navigationService;

    return OBCupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    OBTextFormField(
                      size: OBTextFormFieldSize.large,
                      autofocus: true,
                      obscureText: true,
                      controller: _currentPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        hintText: 'Enter your current password',
                      ),
                      validator: (String password) {
                        if (!_formWasSubmitted) return null;
                        String validatePassword =
                            _validationService.validateUserPassword(password);
                        if (validatePassword != null) return validatePassword;
                      },
                    ),
                  ]),
            ),
          ),
        ));
  }

  Widget _buildNavigationBar() {
    return OBThemedNavigationBar(
      title: 'Delete account',
      trailing: OBButton(
        isDisabled: !_formValid,
        size: OBButtonSize.small,
        onPressed: _submitForm,
        child: Text('Next'),
      ),
    );
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

    var result = await _navigationService.navigateToConfirmDeleteAccount(
        userPassword: _currentPasswordController.text, context: context);
    if (result is bool && !result) {
      _currentPasswordController.clear();
    }
  }

  void _setFormValid(bool formValid) {
    setState(() {
      _formValid = formValid;
    });
  }
}
