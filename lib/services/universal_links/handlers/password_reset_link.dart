import 'dart:async';
import 'package:Buzzing/pages/auth/create_account/blocs/create_account.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/universal_links/universal_links.dart';
import 'package:flutter/material.dart';

class PasswordResetLinkHandler extends UniversalLinkHandler {
  static const String passwordResetVerifyLink = '/api/auth/password/verify';

  @override
  Future handle({BuildContext context, String link}) async{
    if (link.indexOf(passwordResetVerifyLink) != -1) {
      final token = getPasswordResetVerificationTokenFromLink(link);
      BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);
      CreateAccountBloc createAccountBloc = buzzingProvider.createAccountBloc;
      createAccountBloc.setPasswordResetToken(token);
      Navigator.pushReplacementNamed(context, '/auth/set_new_password_step');
    }
  }

  String getPasswordResetVerificationTokenFromLink(String link) {
    final params = Uri.parse(link).queryParametersAll;
    var token = '';
    if (params.containsKey('token')) {
      token = params['token'][0];
    }
    return token;
  }
}
