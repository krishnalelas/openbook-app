import 'package:Buzzing/libs/pretty_count.dart';
import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:flutter/material.dart';

class OBProfileFollowingCount extends StatelessWidget {
  final User user;

  OBProfileFollowingCount(this.user);

  @override
  Widget build(BuildContext context) {
    int followingCount = user.followingCount;

    if (followingCount == null || followingCount == 0) return const SizedBox();

    String count = getPrettyCount(followingCount);

    var buzzingProvider = BuzzingProvider.of(context);
    var themeService = buzzingProvider.themeService;
    var themeValueParserService = buzzingProvider.themeValueParserService;
    var userService = buzzingProvider.userService;
    var navigationService = buzzingProvider.navigationService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;

          return GestureDetector(
            onTap: () {
              if (userService.isLoggedInUser(user)) {
                navigationService.navigateToFollowingPage(context: context);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: count,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: themeValueParserService
                                .parseColor(theme.primaryTextColor))),
                    TextSpan(
                        text: ' Following',
                        style: TextStyle(
                            color: themeValueParserService
                                .parseColor(theme.secondaryTextColor)))
                  ])),
                ),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
          );
        });
  }
}
