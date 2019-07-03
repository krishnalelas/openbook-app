import 'package:Buzzing/models/category.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/theme_value_parser.dart';
import 'package:Buzzing/widgets/tabs/image_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

class OBCategoryTab extends StatelessWidget {
  final Category category;

  const OBCategoryTab({Key key, @required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    ThemeValueParserService _themeValueParser = BuzzingProvider.of(context).themeValueParserService;

    Color categoryColor = _themeValueParser.parseColor(category.color);
    bool categoryColorIsDark = _themeValueParser.isDarkColor(categoryColor);

    return OBImageTab(
      text: category.title,
      color: categoryColor,
      textColor: categoryColorIsDark ? Colors.white : Colors.black,
      imageProvider:
      AdvancedNetworkImage(category.avatar, useDiskCache: true),
    );
  }
}
