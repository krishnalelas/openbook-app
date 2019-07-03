import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/provider.dart';
import 'package:flutter/material.dart';

class OBPrimaryColorContainer extends StatelessWidget {
  final Widget child;
  final BoxDecoration decoration;
  final MainAxisSize mainAxisSize;

  const OBPrimaryColorContainer(
      {Key key,
      this.child,
      this.decoration,
      this.mainAxisSize = MainAxisSize.max})
      : super(key: key);

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

          Widget container = DecoratedBox(
            decoration: BoxDecoration(
                color: themeValueParserService.parseColor(theme.primaryColor),
                borderRadius: decoration?.borderRadius),
            child: child,
          );

          if (mainAxisSize == MainAxisSize.min) {
            return container;
          }

          return Column(
            mainAxisSize: mainAxisSize,
            children: <Widget>[Expanded(child: container)],
          );
        });
  }
}
