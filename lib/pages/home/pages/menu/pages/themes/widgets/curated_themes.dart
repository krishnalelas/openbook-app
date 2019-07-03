import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/pages/home/pages/menu/pages/themes/widgets/theme_preview.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/services/theme.dart';
import 'package:flutter/material.dart';

class OBCuratedThemes extends StatelessWidget {
  ThemeService _themeService;

  @override
  Widget build(BuildContext context) {
    _themeService = BuzzingProvider.of(context).themeService;

    return Padding(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GridView.extent(
                padding: EdgeInsets.symmetric(vertical: 20),
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                maxCrossAxisExtent: OBThemePreview.maxWidth,
                children: _buildThemePreviews(),
                shrinkWrap: true,
              ),
            ],
          ),
        ));
  }

  List<Widget> _buildThemePreviews() {
    var themes = _themeService.getCuratedThemes();
    var res = <Widget>[];

    for (var theme in themes) {
      var builder = Builder(builder: (buildContext) {
        return OBThemePreview(
          theme,
          onThemePreviewPressed: (OBTheme theme) {
            _themeService.setActiveTheme(theme);
          },
        );
      });

      res.add(builder);
    }

    return res;
  }
}
