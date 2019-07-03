import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBUsefulLinksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    var urlLauncherService = buzzingProvider.urlLauncherService;

    return CupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: 'Useful links',
      ),
      child: OBPrimaryColorContainer(
        child: Column(
          children: <Widget>[
            Expanded(
                child: ListView(
              physics: const ClampingScrollPhysics(),
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: const OBIcon(OBIcons.guide),
                  title: OBText('Buzzing guidelines'),
                  subtitle: OBSecondaryText(
                      'The guidelines we\'re all expected to follow for a healthy and friendly co-existence.'),
                  onTap: () {
                    BuzzingProviderState buzzingProvider =
                        BuzzingProvider.of(context);
                    buzzingProvider.navigationService
                        .navigateToCommunityGuidelinesPage(context: context);
                  },
                ),
                ListTile(
                  leading: const OBIcon(OBIcons.dashboard),
                  title: OBText('Github project board'),
                  subtitle: OBSecondaryText(
                      'Take a look at what we\'re currently working on'),
                  onTap: () {
                    urlLauncherService.launchUrl(
                        'https://github.com/orgs/BuzzingOrg/projects/3');
                  },
                ),
                ListTile(
                  leading: const OBIcon(OBIcons.featureRequest),
                  title: OBText('Feature requests'),
                  subtitle: OBSecondaryText(
                      'Request a feature or upvote existing requests'),
                  onTap: () {
                    urlLauncherService.launchUrl(
                        'https://buzzing.canny.io/feature-requests');
                  },
                ),
                ListTile(
                  leading: const OBIcon(OBIcons.bug),
                  title: OBText('Bug tracker'),
                  subtitle:
                      OBSecondaryText('Report a bug or upvote existing bugs'),
                  onTap: () {
                    urlLauncherService
                        .launchUrl('https://buzzing.canny.io/bugs');
                  },
                ),
                ListTile(
                  leading: const OBIcon(OBIcons.guide),
                  title: OBText('Buzzing handbook'),
                  subtitle: OBSecondaryText(
                      'A book with everything there is to know about using the platform'),
                  onTap: () {
                    urlLauncherService.launchUrl('https://buzzing.support/');
                  },
                ),
                ListTile(
                  leading: const OBIcon(OBIcons.slackChannel),
                  title: OBText('Community slack channel'),
                  subtitle: OBSecondaryText(
                      'A place to discuss everything about Buzzing'),
                  onTap: () {
                    urlLauncherService.launchUrl(
                        'https://join.slack.com/t/buzzingorg/shared_invite/enQtNDI2NjI3MDM0MzA2LTYwM2E1Y2NhYWRmNTMzZjFhYWZlYmM2YTQ0MWEwYjYyMzcxMGI0MTFhNTIwYjU2ZDI1YjllYzlhOWZjZDc4ZWY');
                  },
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
