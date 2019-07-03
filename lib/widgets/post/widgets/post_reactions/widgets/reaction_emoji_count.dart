import 'package:Buzzing/models/post_reactions_emoji_count.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

class OBEmojiReactionCount extends StatelessWidget {
  final PostReactionsEmojiCount postReactionsEmojiCount;
  final bool reacted;
  final ValueChanged<PostReactionsEmojiCount> onPressed;
  final ValueChanged<PostReactionsEmojiCount> onLongPressed;

  const OBEmojiReactionCount(this.postReactionsEmojiCount,
      {this.onPressed, this.reacted, this.onLongPressed});

  @override
  Widget build(BuildContext context) {
    var emoji = postReactionsEmojiCount.emoji;

    return GestureDetector(
      onTap: () {
        if (onPressed != null) onPressed(postReactionsEmojiCount);
      },
      onLongPress: () {
        if (onLongPressed != null) onLongPressed(postReactionsEmojiCount);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(
              height: 18.0,
              image: AdvancedNetworkImage(emoji.image, useDiskCache: true),
            ),
            const SizedBox(
              width: 10.0,
            ),
            OBText(
              postReactionsEmojiCount.getPrettyCount(),
              style: TextStyle(
                  fontWeight: reacted ? FontWeight.bold : FontWeight.normal),
            )
          ],
        ),
      ),
    );
  }
}
