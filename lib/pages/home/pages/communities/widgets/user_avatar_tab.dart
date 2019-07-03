import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/theme.dart';
import 'package:Buzzing/services/theme_value_parser.dart';
import 'package:Buzzing/widgets/alerts/alert.dart';
import 'package:Buzzing/widgets/avatars/avatar.dart';
import 'package:Buzzing/widgets/tabs/image_tab.dart';
import 'package:flutter/material.dart';

class OBUserAvatarTab extends StatelessWidget {
  final User user;

  const OBUserAvatarTab({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);
    ThemeService _themeService = buzzingProvider.themeService;
    ThemeValueParserService _themeValueParser =
        buzzingProvider.themeValueParserService;
    OBTheme theme = _themeService.getActiveTheme();

    Gradient themeGradient =
        _themeValueParser.parseGradient(theme.primaryAccentColor);

    return OBAlert(
        borderRadius: BorderRadius.circular(OBImageTab.borderRadius),
        padding: EdgeInsets.all(0),
        height: OBImageTab.height,
        width: OBImageTab.width * 0.8,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              OBAvatar(
                size: OBAvatarSize.small,
                avatarUrl: user.getProfileAvatar(),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                          gradient: themeGradient,
                          borderRadius: BorderRadius.only(
                              bottomLeft:
                                  Radius.circular(OBImageTab.borderRadius),
                              bottomRight:
                                  Radius.circular(OBImageTab.borderRadius))),
                      child: Text(
                        'You',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
