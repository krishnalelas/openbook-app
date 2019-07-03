import 'package:flutter/material.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/pages/auth/create_account/create_account.dart';
import 'package:Buzzing/pages/auth/create_account/done_step.dart';
import 'package:Buzzing/pages/auth/create_account/email_step.dart';
import 'package:Buzzing/pages/auth/create_account/guidelines_step.dart';
import 'package:Buzzing/pages/auth/reset_password/forgot_password_step.dart';
import 'package:Buzzing/pages/auth/create_account/get_started.dart';
import 'package:Buzzing/pages/auth/create_account/legal_age_step.dart';
import 'package:Buzzing/pages/auth/create_account/submit_step.dart';
import 'package:Buzzing/pages/auth/create_account/password_step.dart';
import 'package:Buzzing/pages/auth/reset_password/reset_password_success_step.dart';
import 'package:Buzzing/pages/auth/reset_password/set_new_password_step.dart';
import 'package:Buzzing/pages/auth/reset_password/verify_reset_password_link_step.dart';
import 'package:Buzzing/pages/auth/login.dart';
import 'package:Buzzing/pages/auth/splash.dart';
import 'package:Buzzing/pages/home/home.dart';
import 'package:Buzzing/pages/waitlist/subscribe_done_step.dart';
import 'package:Buzzing/pages/waitlist/subscribe_email_step.dart';
import 'package:Buzzing/services/localization.dart';
import 'package:Buzzing/services/universal_links/universal_links.dart';
import 'package:Buzzing/pages/auth/create_account/name_step.dart';

class Routes {
  /*static UserModel _userModel;

  Routes.init(UserModel  userModel){
    _userModel =userModel;
  }*/
  static final routes = <String, WidgetBuilder>{
    /*RouteNames.ROUTE_SETTINGS: (BuildContext context) =>
        MyBlocProvider(
          bloc: SettingsBloc(UserSettingsDB.get()),
          child: SettingsPage(_userModel),
        ),
    Constants.ROUTE_HOME_VIEW: (BuildContext context) =>
        BlocProvider(
          bloc: HomeBloc(),
          child: HomePage(),
        ),
    Constants.ROUTE_SCHOOL_LIST_VIEW: (BuildContext context) =>
        SchoolListView(),
    Constants.ROUTE_SCREENING_TYPE_LIST_VIEW: (BuildContext context) =>
        ScreeningTypeListView(),
    Constants.ROUTE_STUDENT_LIST_VIEW: (BuildContext context) =>
        StudentListView()*/

    /// The buzzingProvider uses services available in the context
    /// Their connection must be bootstrapped but no other way to execute
    /// something before loading any route, therefore this ugliness.
    RouteNames.HOME: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBHomePage();
    },
    RouteNames.AUTH: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      //return OBAuthSplashPage();
      return OBAuthLoginPage();
    },
    RouteNames.AUTH_TOKEN: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthCreateAccountPage();
    },
    RouteNames.GET_STARTED: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthGetStartedPage();
    },
    RouteNames.GUIDELINES_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthGuidelinesStepPage();
    },
    RouteNames.LEGAL_AGE_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthLegalAgeStepPage();
    },
    RouteNames.NAME_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthNameStepPage();
    },
    RouteNames.EMAIL_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthEmailStepPage();
    },
    RouteNames.PASSWORD_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthPasswordStepPage();
    },
    RouteNames.SUBMIT_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthSubmitPage();
    },
    RouteNames.DONE_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthDonePage();
    },
    RouteNames.LOGIN: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthLoginPage();
    },
    RouteNames.FORGOT_PASSWORD_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthForgotPasswordPage();
    },
    RouteNames.VERIFY_RESET_PASSWORD_LINK_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthVerifyPasswordPage();
    },
    RouteNames.SET_NEW_PASSWORD_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthSetNewPasswordPage();
    },
    RouteNames.PASSWORD_RESET_SUCCESS_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBAuthPasswordResetSuccessPage();
    },
    RouteNames.SUBSCRIBE_EMAIL_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      return OBWaitlistSubscribePage();
    },
    RouteNames.SUBSCRIBE_DONE_STEP: (BuildContext context) {
      bootstrapbuzzingProviderInContext(context);
      WaitlistSubscribeArguments args =
          ModalRoute.of(context).settings.arguments;
      return OBWaitlistSubscribeDoneStep(count: args.count);
    }
  };

  static void bootstrapbuzzingProviderInContext(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    var localizationService = LocalizationService.of(context);
    buzzingProvider.setLocalizationService(localizationService);
    UniversalLinksService universalLinksService =
        buzzingProvider.universalLinksService;
    universalLinksService.digestLinksWithContext(context);
  }
}

class RouteNames {
  static const String HOME = "/";
  static const String AUTH = "/auth";
  static const String AUTH_TOKEN = "/auth/token";
  static const String GET_STARTED = "/auth/get-started";
  static const String GUIDELINES_STEP = "/auth/guidelines_step";
  static const String LEGAL_AGE_STEP = "/auth/legal_age_step";
  static const String NAME_STEP = "/auth/name_step";
  static const String EMAIL_STEP = "/auth/email_step";
  static const String PASSWORD_STEP = "/auth/password_step";
  static const String SUBMIT_STEP = "/auth/submit_step";
  static const String DONE_STEP = "/auth/done_step";
  static const String LOGIN = "/auth/login";
  static const String FORGOT_PASSWORD_STEP = "/auth/forgot_password_step";
  static const String VERIFY_RESET_PASSWORD_LINK_STEP =
      "/auth/verify_reset_password_link_step";
  static const String SET_NEW_PASSWORD_STEP = "/auth/set_new_password_step";
  static const String PASSWORD_RESET_SUCCESS_STEP =
      "/auth/password_reset_success_step";

  static const String SUBSCRIBE_EMAIL_STEP = "/waitlist/subscribe_email_step";
  static const String SUBSCRIBE_DONE_STEP = "/waitlist/subscribe_done_step";
}
