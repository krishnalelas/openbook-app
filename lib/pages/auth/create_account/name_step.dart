import 'package:Buzzing/provider.dart';
import 'package:Buzzing/pages/auth/create_account/blocs/create_account.dart';
import 'package:Buzzing/services/localization.dart';
import 'package:Buzzing/services/validation.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/buttons/success_button.dart';
import 'package:Buzzing/widgets/buttons/secondary_button.dart';
import 'package:Buzzing/pages/auth/create_account/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class OBAuthNameStepPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBAuthNameStepPageState();
  }
}

class OBAuthNameStepPageState extends State<OBAuthNameStepPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  CreateAccountBloc _createAccountBloc;
  LocalizationService _localizationService;
  ValidationService _validationService;

  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _localizationService = buzzingProvider.localizationService;
    _createAccountBloc = buzzingProvider.createAccountBloc;
    _validationService = buzzingProvider.validationService;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    _buildWhatYourName(context: context),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _buildNameForm(),
                  ],
                ))),
      ),
      backgroundColor: Color(0xFF9013FE),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0.0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: _buildPreviousButton(context: context),
              ),
              Expanded(child: _buildNextButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    String buttonText = _localizationService.trans('AUTH.CREATE_ACC.NEXT');
    return OBSuccessButton(
      minWidth: double.infinity,
      size: OBButtonSize.large,
      child: Text(buttonText, style: TextStyle(fontSize: 18.0)),
      onPressed: onPressedNextStep,
    );
  }


  bool _validateForm() {
    return _formKey.currentState.validate();
  }

  void onPressedNextStep() {
    bool isNameValid = _validateForm();
    if (isNameValid) {
      setState(() {
        _createAccountBloc.setName(_nameController.text);
        Navigator.pushNamed(context, '/auth/email_step');
      });
    }
  }

  Widget _buildPreviousButton({@required BuildContext context}) {
    String buttonText = _localizationService.trans('AUTH.CREATE_ACC.PREVIOUS');

    return OBSecondaryButton(
      isFullWidth: true,
      isLarge: true,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            buttonText,
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )
        ],
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildWhatYourName({@required BuildContext context}) {
    String whatNameText =
        _localizationService.trans('AUTH.CREATE_ACC.WHAT_NAME');

    return Column(
      children: <Widget>[
        Text(
          '📛',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(whatNameText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildNameForm() {

    String nameInputPlaceholder =
        _localizationService.trans('AUTH.CREATE_ACC.NAME_PLACEHOLDER');

    return Form(
      key: _formKey,
      child: Row(children: <Widget>[
        new Expanded(
          child: Container(
              color: Colors.transparent,
              child: OBAuthTextField(
                textCapitalization: TextCapitalization.words,
                autocorrect: false,
                hintText: nameInputPlaceholder,
                validator: (String name) {
                  String validateName = _validationService
                      .validateUserProfileName(name);
                  if (validateName != null) return validateName;
                },
                controller: _nameController,
              )
          ),
        ),
      ]),
    );
  }
}
