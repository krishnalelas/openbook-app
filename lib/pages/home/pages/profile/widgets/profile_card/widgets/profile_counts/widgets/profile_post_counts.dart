import 'package:Buzzing/libs/pretty_count.dart';
import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:flutter/material.dart';

class OBProfilePostsCount extends StatelessWidget {
  final User user;

  OBProfilePostsCount(this.user);

  @override
  Widget build(BuildContext context) {
    int postsCount = user.postsCount;

    if (postsCount == null || postsCount == 0) return const SizedBox();

    String count = getPrettyCount(postsCount);

    var buzzingProvider = BuzzingProvider.of(context);
    var themeService = buzzingProvider.themeService;
    var themeValueParserService = buzzingProvider.themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;

          return Row(
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
                          color: themeValueParserService.parseColor(theme.primaryTextColor))),
                  TextSpan(
                      text: postsCount == 1 ? ' Post' : ' Posts',
                      style: TextStyle(
                          color: themeValueParserService.parseColor(theme.secondaryTextColor)))
                ])),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          );
        });
  }
}
