import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';

class OBSecondaryText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final OBTextSize size;
  final TextOverflow overflow;
  final TextAlign textAlign;

  const OBSecondaryText(this.text,
      {this.style, this.size, this.overflow, this.textAlign});

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

          TextStyle finalStyle = style;
          TextStyle themedTextStyle = TextStyle(
              color:
                  themeValueParserService.parseColor(theme.secondaryTextColor));

          if (finalStyle != null) {
            finalStyle = finalStyle.merge(themedTextStyle);
          } else {
            finalStyle = themedTextStyle;
          }

          return OBText(
            text,
            style: finalStyle,
            size: size,
            overflow: overflow,
            textAlign: textAlign,
          );
        });
  }
}
