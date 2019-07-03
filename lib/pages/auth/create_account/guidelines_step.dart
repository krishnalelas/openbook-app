import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/pages/auth/create_account/blocs/create_account.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/documents.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/localization.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/widgets/alerts/alert.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/buttons/secondary_button.dart';
import 'package:Buzzing/widgets/buttons/success_button.dart';
import 'package:Buzzing/widgets/markdown.dart';
import 'package:Buzzing/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:pigment/pigment.dart';

class OBAuthGuidelinesStepPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBAuthGuidelinesStepPageState();
  }
}

class OBAuthGuidelinesStepPageState extends State<OBAuthGuidelinesStepPage> {
  CreateAccountBloc _createAccountBloc;
  LocalizationService _localizationService;
  DocumentsService _documentsService;
  ToastService _toastService;
  bool _needsBootstrap;
  bool _acceptButtonEnabled;
  bool _requestInProgress;
  String _communityGuidelines;
  ScrollController _guidelinesScrollController;

  @override
  void initState() {
    _requestInProgress = false;
    _needsBootstrap = true;
    _communityGuidelines = '';
    _acceptButtonEnabled = false;
    _guidelinesScrollController = ScrollController();
    _guidelinesScrollController.addListener(_onGuidelinesScroll);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _guidelinesScrollController.removeListener(_onGuidelinesScroll);
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var buzzingProvider = BuzzingProvider.of(context);
      _localizationService = buzzingProvider.localizationService;
      _createAccountBloc = buzzingProvider.createAccountBloc;
      _documentsService = buzzingProvider.documentsService;
      _bootstrap();
      _needsBootstrap = false;
    }
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Text(
              'Please take a moment to read and accept our guidelines.',
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20),
              child: OBAlert(
                child: ListView(
                  controller: _guidelinesScrollController,
                  children: <Widget>[
                    _requestInProgress
                        ? Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: OBProgressIndicator(color: Colors.white,),
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          )
                        : OBMarkdown(
                            onlyBody: true,
                            data: _communityGuidelines,
                            theme: OBTheme(
                              primaryTextColor: '#ffffff',
                              secondaryTextColor: '#b3b3b3',
                              primaryColor: '#000000',
                              primaryAccentColor: '#ffffff,#ffffff',
                              successColor: '#7ED321',
                              successColorAccent: '#ffffff',
                              dangerColor: '#FF3860',
                              dangerColorAccent: '#ffffff',
                            ),
                          )
                  ],
                ),
              ),
            ),
          )
        ],
      )),
      backgroundColor: Pigment.fromString('#9966cc'),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0.0,
        child: Container(
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

  void _bootstrap() async {
    return _refreshGuidelines();
  }

  void _refreshGuidelines() async {
    _setRequestInProgress(true);

    try {
      String communityGuidelines =
          await _documentsService.getCommunityGuidelines();
      _setCommunityGuidelines(communityGuidelines);
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
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

  void _onGuidelinesScroll() {
    if (!_acceptButtonEnabled &&
        _guidelinesScrollController.position.pixels >
            (_guidelinesScrollController.position.maxScrollExtent * 0.9)) {
      _setAcceptButtonEnabled(true);
    }
  }

  Widget _buildNextButton() {
    return OBSuccessButton(
      minWidth: double.infinity,
      size: OBButtonSize.large,
      child: Text('Accept', style: TextStyle(fontSize: 18.0)),
      isDisabled: !_acceptButtonEnabled &&
          !_createAccountBloc.areGuidelinesAccepted() &&
          _communityGuidelines.isNotEmpty,
      onPressed: () {
        _createAccountBloc.setAreGuidelinesAcceptedConfirmation(true);
        Navigator.pushNamed(context, '/auth/legal_age_step');
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
          SizedBox(
            width: 10.0,
          ),
          Text(
            buttonText,
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          )
        ],
      ),
      onPressed: () {
        _createAccountBloc.setAreGuidelinesAcceptedConfirmation(false);
        Navigator.pop(context);
      },
    );
  }

  void _setCommunityGuidelines(String communityGuidelines) {
    setState(() {
      _communityGuidelines = communityGuidelines;
    });
  }

  void _setAcceptButtonEnabled(bool acceptButtonEnabled) {
    setState(() {
      _acceptButtonEnabled = acceptButtonEnabled;
    });
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }
}
