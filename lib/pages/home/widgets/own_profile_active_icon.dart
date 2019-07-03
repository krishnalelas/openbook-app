import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/avatars/avatar.dart';
import 'package:flutter/cupertino.dart';

class OBOwnProfileActiveIcon extends StatelessWidget {
  final String avatarUrl;
  final OBAvatarSize size;

  const OBOwnProfileActiveIcon({Key key, this.avatarUrl, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var themeService = BuzzingProvider.of(context).themeService;
    var themeValueParserService =
        BuzzingProvider.of(context).themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(500),
                border: Border.all(
                    color: themeValueParserService
                        .parseGradient(theme.primaryAccentColor).colors[1])),
            padding: EdgeInsets.all(2.0),
            child: OBAvatar(
              avatarUrl: avatarUrl,
              size: size,
            ),
          );
        });
  }
}
