import 'package:Buzzing/models/circle.dart';
import 'package:Buzzing/models/post.dart';
import 'package:Buzzing/widgets/cirles_wrap.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/actionable_smart_text.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBPostIsClosed extends StatelessWidget {
  final Post _post;

  OBPostIsClosed(this._post);

  @override
  Widget build(BuildContext context) {
    bool isClosed = _post.isClosed ?? false;

    if (isClosed) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: <Widget>[
            const OBIcon(OBIcons.closePost, size: OBIconSize.small,),
            const SizedBox(width: 10,),
            const OBText('Closed post', size: OBTextSize.small)
          ],
        ),
      );
    }

    return const SizedBox();
  }
}
