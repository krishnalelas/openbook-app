import 'package:Buzzing/pages/waitlist/subscribe_done_step.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/localization.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/services/validation.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/buttons/success_button.dart';
import 'package:Buzzing/widgets/buttons/secondary_button.dart';
import 'package:Buzzing/pages/auth/create_account/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

class OBWaitlistSubscribePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBWaitlistSubscribePageState();
  }
}

class OBWaitlistSubscribePageState extends State<OBWaitlistSubscribePage> {
  bool _subscribeInProgress;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSubmitted;
  UserService _userService;
  LocalizationService _localizationService;
  ValidationService _validationService;
  ToastService _toastService;

  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isSubmitted = false;
    _subscribeInProgress = false;
    _emailController.addListener(_validateForm);
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _localizationService = buzzingProvider.localizationService;
    _validationService = buzzingProvider.validationService;
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: <Widget>[
                    _buildSubscribeEmailText(context: context),
                    const SizedBox(
                      height: 20.0,
                    ),
                    _buildEmailForm()
                  ],
                ))),
      ),
      backgroundColor: Color(0xFFFFB649),
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
    if (!_isSubmitted) return null;
    return _formKey.currentState.validate();
  }

  void onPressedNextStep(BuildContext context) async {
    if (_subscribeInProgress) return;
    _isSubmitted = true;
    bool isEmailValid = _validateForm();

    if (!isEmailValid) return;

    _setSubscribeInProgress(true);
    try {
      int count = await _userService.subscribeToBetaWaitlist(
          email: _emailController.text);
      WaitlistSubscribeArguments args =
          new WaitlistSubscribeArguments(count: count);
      Navigator.pushNamed(context, '/waitlist/subscribe_done_step',
          arguments: args);
    } catch (error) {
      _onError(error);
    } finally {
      _setSubscribeInProgress(false);
    }
  }

  Widget _buildNextButton(BuildContext context) {
    String buttonText = _localizationService.trans('AUTH.CREATE_ACC.SUBSCRIBE');

    return OBSuccessButton(
      minWidth: double.infinity,
      size: OBButtonSize.large,
      isLoading: _subscribeInProgress,
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

  Widget _buildSubscribeEmailText({@required BuildContext context}) {
    String subscribeEmailText = _localizationService
        .trans('AUTH.CREATE_ACC.SUBSCRIBE_TO_WAITLIST_TEXT');

    return Column(
      children: <Widget>[
        Text(
          '💌',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(subscribeEmailText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    );
  }

  Widget _buildEmailForm() {
    String emailInputPlaceholder =
        _localizationService.trans('AUTH.CREATE_ACC.EMAIL_PLACEHOLDER');

    return Form(
      key: _formKey,
      child: Row(children: <Widget>[
        new Expanded(
          child: Container(
              color: Colors.transparent,
              child: OBAuthTextField(
                autocorrect: false,
                hintText: emailInputPlaceholder,
                validator: (String email) {
                  String validateEMail =
                      _validationService.validateUserEmail(email);
                  if (validateEMail != null) return validateEMail;
                },
                controller: _emailController,
              )),
        ),
      ]),
    );
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

  void _setSubscribeInProgress(subscribeInProgress) {
    setState(() {
      _subscribeInProgress = subscribeInProgress;
    });
  }
}
