import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/theme_value_parser.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class OBCommunityNavBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final Community community;

  const OBCommunityNavBar(this.community);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: community.updateSubject,
        initialData: community,
        builder: (BuildContext context, AsyncSnapshot<Community> snapshot) {
          var community = snapshot.data;

          String communityColor = community.color;
          ThemeValueParserService themeValueParserService =
              BuzzingProvider.of(context).themeValueParserService;
          Color color = themeValueParserService.parseColor(communityColor);
          bool isDarkColor = themeValueParserService.isDarkColor(color);
          Color actionsColor = isDarkColor ? Colors.white : Colors.black;

          return CupertinoNavigationBar(
            border: null,
            actionsForegroundColor: actionsColor,
            middle: Text(
              '/c/' + community.name,
              style: TextStyle(color: actionsColor),
            ),
            transitionBetweenRoutes: false,
            backgroundColor: color,
          );
        });
  }

  bool get fullObstruction {
    return true;
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(44);
  }
}
