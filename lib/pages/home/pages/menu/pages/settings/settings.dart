import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    var navigationService = buzzingProvider.navigationService;

    return CupertinoPageScaffold(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      navigationBar: OBThemedNavigationBar(title: 'Settings'),
      child: OBPrimaryColorContainer(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              leading: const OBIcon(OBIcons.account),
              title: OBText('Account settings'),
              onTap: () {
                navigationService.navigateToAccountSettingsPage(
                    context: context);
              },
            ),
            ListTile(
              leading: const OBIcon(OBIcons.application),
              title: OBText('Application settings'),
              onTap: () {
                navigationService.navigateToApplicationSettingsPage(
                    context: context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
