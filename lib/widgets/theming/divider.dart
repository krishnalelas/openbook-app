import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/provider.dart';
import 'package:flutter/material.dart';
import 'package:tinycolor/tinycolor.dart';

class OBDivider extends StatelessWidget {

  const OBDivider();

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    var themeService = buzzingProvider.themeService;
    var themeValueParserService = buzzingProvider.themeValueParserService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;

          return SizedBox(
            height: 16.0,
            child: Center(
              child: Container(
                height: 0.0,
                margin: EdgeInsetsDirectional.only(start: 0),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                    color: themeValueParserService
                        .parseColor(theme.secondaryTextColor),
                    width: 0.5,
                  )),
                ),
              ),
            ),
          );
        });
  }
}
