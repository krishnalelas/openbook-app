import 'dart:io';

import 'package:Buzzing/delegates/localization_delegate.dart';
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
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/pages/auth/create_account/name_step.dart';
import 'package:Buzzing/plugins/desktop/error-reporting.dart';
import 'package:Buzzing/services/localization.dart';
import 'package:Buzzing/services/universal_links/universal_links.dart';
import 'package:Buzzing/route/routes.dart';
import 'package:Buzzing/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'package:sentry/sentry.dart';
import 'dart:async';

class MyApp extends StatelessWidget {
  final buzzingProviderKey = new GlobalKey<BuzzingProviderState>();

  @override
  Widget build(BuildContext context) {
    var textTheme = _defaultTextTheme();
    return BuzzingProvider(
      key: buzzingProviderKey,
      child: OBToast(
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'buzzing',
            supportedLocales: [
              const Locale('en', 'US'),
              const Locale('es', 'ES'),
            ],
            localizationsDelegates: [
              const LocalizationServiceDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            theme: new ThemeData(
                buttonTheme: ButtonThemeData(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(2.0))),
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
                // counter didn't reset back to zero; the application is not restarted.
                primarySwatch: Colors.grey,
                fontFamily: 'OpenSans',
                textTheme: textTheme,
                primaryTextTheme: textTheme,
                accentTextTheme: textTheme),
            routes: Routes.routes ,
        )
      ),
    );
  }

  /*void bootstrapbuzzingProviderInContext(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    var localizationService = LocalizationService.of(context);
    buzzingProvider.setLocalizationService(localizationService);
    UniversalLinksService universalLinksService =
        buzzingProvider.universalLinksService;
    universalLinksService.digestLinksWithContext(context);
  }*/
}

void _setPlatformOverrideForDesktop() {
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

Future<Null> main() async {
  _setPlatformOverrideForDesktop();
  // This captures errors reported by the Flutter framework.
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isOnDesktop) {
      // Report errors on Desktop to embedder
      DesktopErrorReporting.reportError(details.exception, details.stack);
    } else if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  // This creates a [Zone] that contains the Flutter application and stablishes
  // an error handler that captures errors and reports them.
  //
  // Using a zone makes sure that as many errors as possible are captured,
  // including those thrown from [Timer]s, microtasks, I/O, and those forwarded
  // from the `FlutterError` handler.
  //
  // More about zones:
  //
  // - https://api.dartlang.org/stable/1.24.2/dart-async/Zone-class.html
  // - https://www.dartlang.org/articles/libraries/zones

  MyApp app;
  runZoned<Future<Null>>(() async {
    app = MyApp();
    runApp(app);
  }, onError: (error, stackTrace) async {
    if (isOnDesktop) {
      DesktopErrorReporting.reportError(error, stackTrace);
      return;
    }
    SentryClient sentryClient =
        app.buzzingProviderKey.currentState.sentryClient;
    await _reportError(error, stackTrace, sentryClient);
  });
}

/// Reports [error] along with its [stackTrace] to Sentry.io.
Future<Null> _reportError(
    dynamic error, dynamic stackTrace, SentryClient sentryClient) async {
  print('Caught error: $error');

  // Errors thrown in development mode are unlikely to be interesting. You can
  // check if you are running in dev mode using an assertion and omit sending
  // the report.
  if (isInDebugMode) {
    print(stackTrace);
    print('In dev mode. Not sending report to Sentry.io.');
    return;
  }

  print('Reporting to Sentry.io...');
  final SentryResponse response = await sentryClient.captureException(
    exception: error,
    stackTrace: stackTrace,
  );

  if (response.isSuccessful) {
    print('Success! Event ID: ${response.eventId}');
  } else {
    print('Failed to report to Sentry.io: ${response.error}');
  }
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

bool get isOnDesktop {
  return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}

TextTheme _defaultTextTheme() {
  // This text theme is merged with the default theme in the `TextData`
  // constructor. This makes sure that the emoji font is used as fallback for
  // every text that uses the default theme.
  var style;
  if (isOnDesktop) {
    style = new TextStyle(fontFamilyFallback: ['Emoji']);
  }
  return new TextTheme(
    body1: style,
    body2: style,
    button: style,
    caption: style,
    display1: style,
    display2: style,
    display3: style,
    display4: style,
    headline: style,
    overline: style,
    subhead: style,
    subtitle: style,
    title: style,
  );
}
