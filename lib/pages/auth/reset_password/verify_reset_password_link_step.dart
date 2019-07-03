import 'package:Buzzing/provider.dart';
import 'package:Buzzing/pages/auth/create_account/blocs/create_account.dart';
import 'package:Buzzing/services/localization.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/validation.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/buttons/success_button.dart';
import 'package:Buzzing/widgets/buttons/secondary_button.dart';
import 'package:Buzzing/pages/auth/create_account/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class OBAuthVerifyPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBAuthVerifyPasswordPageState();
  }
}

class OBAuthVerifyPasswordPageState extends State<OBAuthVerifyPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CreateAccountBloc _createAccountBloc;
  LocalizationService _localizationService;
  ValidationService _validationService;
  ToastService _toastService;

  TextEditingController _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _localizationService = buzzingProvider.localizationService;
    _validationService = buzzingProvider.validationService;
    _createAccountBloc = buzzingProvider.createAccountBloc;
    _toastService = buzzingProvider.toastService;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    _buildPasteRegisterLink(context: context),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _buildLinkForm(),
                    const SizedBox(
                        height: 20.0
                    )
                  ],
                ))),
      ),
      backgroundColor: Colors.amber,
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
              Expanded(child: _buildNextButton(context)),
            ],
          ),
        ),
      ),
    );
  }


  bool _validateForm() {
    return _formKey.currentState.validate();
  }

  void onPressedNextStep(BuildContext context) {
    bool isLinkValid = _validateForm();
    if (isLinkValid) {
      setState(() {
        var passwordResetToken = _getTokenFromLink(_linkController.text);
        _createAccountBloc.setPasswordResetToken(passwordResetToken);
        Navigator.pushNamed(context, '/auth/set_new_password_step');
      });
    }
  }

  String _getTokenFromLink(String link) {
    final uri = Uri.decodeFull(link);
    final params = Uri.parse(uri).queryParametersAll;
    var token = '';
    if (params.containsKey('token')) {
      token = params['token'][0];
    } else {
      token = uri.split('?token=')[1];
    }
    return token;
  }

  Widget _buildNextButton(BuildContext context) {
    String buttonText = _localizationService.trans('AUTH.CREATE_ACC.NEXT');

    return OBSuccessButton(
      minWidth: double.infinity,
      size: OBButtonSize.large,
      child: Text(buttonText, style: TextStyle(fontSize: 18.0)),
      onPressed: () {
        onPressedNextStep(context);
      },
    );
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

  Widget _buildPasteRegisterLink({@required BuildContext context}) {
    String pasteLinkText =
    _localizationService.trans('AUTH.CREATE_ACC.PASTE_PASSWORD_RESET_LINK');

    return Column(
      children: <Widget>[
        Text(
          '🔒',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(pasteLinkText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildLinkForm() {

    return Form(
      key: _formKey,
      child: Row(children: <Widget>[
        new Expanded(
          child: Container(
              color: Colors.transparent,
              child: OBAuthTextField(
                autocorrect: false,
                hintText: '',
                validator: (String link) {
                  String validateLink = _validationService.validateUserRegistrationLink(link);
                  if (validateLink != null) {
                    return validateLink;
                  }
                },
                controller: _linkController,
              )
          ),
        ),
      ]),
    );
  }
}
