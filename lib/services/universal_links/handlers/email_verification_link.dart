import 'dart:async';

import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/auth_api.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/universal_links/universal_links.dart';
import 'package:Buzzing/services/user.dart';
import 'package:flutter/material.dart';

class EmailVerificationLinkHandler extends UniversalLinkHandler {
  static const String verifyEmailLink = '/api/auth/email/verify';
  StreamSubscription _onLoggedInUserChangeSubscription;

  @override
  Future handle({BuildContext context, String link}) async{
    if (link.indexOf(verifyEmailLink) != -1) {
      final token = _getEmailVerificationTokenFromLink(link);
      BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);
      UserService userService = buzzingProvider.userService;
      ToastService toastService = buzzingProvider.toastService;
      AuthApiService authApiService = buzzingProvider.authApiService;

      _onLoggedInUserChangeSubscription =
          userService.loggedInUserChange.listen((User newUser) async {
        _onLoggedInUserChangeSubscription.cancel();

        try {
          HttpieResponse response =
              await authApiService.verifyEmailWithToken(token);
          if (response.isOk()) {
            toastService.success(
                message: 'Awesome! Your email is now verified', context: context);
          } else if (response.isBadRequest()) {
            toastService.error(
                message:
                'Oops! Your token was not valid or expired, please try again',
                context: context);
          }
        } on HttpieConnectionRefusedError {
          toastService.error(message: 'No internet connection', context: null);
        } catch (e) {
          toastService.error(message: 'Unknown error.', context: null);
          rethrow;
        }
      });
    }
  }

  String _getEmailVerificationTokenFromLink(String link) {
    final linkParts = _getDeepLinkParts(link);
    return linkParts[linkParts.length - 1];
  }

  List<String> _getDeepLinkParts(String link) {
    final uri = Uri.parse(link);
    return uri.path.split('/');
  }
}
