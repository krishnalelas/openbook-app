import 'package:Buzzing/pages/auth/create_account/blocs/create_account.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/universal_links/universal_links.dart';
import 'package:Buzzing/services/user.dart';
import 'package:flutter/material.dart';

class CreateAccountLinkHandler extends UniversalLinkHandler {
  static const String createAccountLink = '/api/auth/invite';

  @override
  Future<void> handle({BuildContext context, String link}) {
    if (link.indexOf(createAccountLink) != -1) {
      BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);
      UserService userService = buzzingProvider.userService;
      if (userService.isLoggedIn()) {
        print('User already logged in. Doing nothing with create account link');
      } else {
        print(
            'User not yet logged in. Sending to create account route with token');
        final String token = _getAccountCreationTokenFromLink(link);
        CreateAccountBloc createAccountBloc =
            buzzingProvider.createAccountBloc;
        createAccountBloc.setToken(token);
        Navigator.pushReplacementNamed(context, '/auth/get-started');
      }
    }
  }

  String _getAccountCreationTokenFromLink(String link) {
    final params = Uri.parse(link).queryParametersAll;
    var token = '';
    if (params.containsKey('token')) {
      token = params['token'][0];
    }
    return token;
  }
}
