import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCreatePostText extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  String hintText;

  OBCreatePostText({this.controller, this.focusNode, this.hintText});

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

          return TextField(
            controller: controller,
            autofocus: true,
            focusNode: focusNode,
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            style: TextStyle(
                color: themeValueParserService.parseColor(theme.primaryTextColor),
                fontSize: 18.0),
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: this.hintText != null ? this.hintText : 'What\'s going on?',
                hintStyle: TextStyle(
                    color: themeValueParserService
                        .parseColor(theme.secondaryTextColor),
                    fontSize: 18.0)),
            autocorrect: true,
          );
        });
  }
}
