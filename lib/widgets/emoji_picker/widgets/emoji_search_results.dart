import 'package:Buzzing/models/emoji.dart';
import 'package:Buzzing/models/emoji_group.dart';
import 'package:Buzzing/widgets/emoji_picker/emoji_picker.dart';
import 'package:Buzzing/widgets/emoji_picker/widgets/emoji_groups/widgets/emoji_group/widgets/emoji.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OBEmojiSearchResults extends StatelessWidget {
  final List<EmojiGroupSearchResults> results;
  final String searchQuery;
  final OnEmojiPressed onEmojiPressed;

  OBEmojiSearchResults(this.results, this.searchQuery,
      {Key key, @required this.onEmojiPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return results.length > 0 ? _buildSearchResults() : _buildNoResults();
  }

  Widget _buildSearchResults() {
    return ListView.builder(
        physics: const ClampingScrollPhysics(),
        itemCount: results.length,
        itemBuilder: (BuildContext context, int index) {
          EmojiGroupSearchResults searchResults = results[index];
          EmojiGroup emojiGroup = searchResults.group;
          List<Emoji> emojiSearchResults = searchResults.searchResults;

          List<Widget> emojiTiles = emojiSearchResults.map((Emoji emoji) {
            return ListTile(
              onTap: () {
                onEmojiPressed(emoji, emojiGroup);
              },
              leading: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 25),
                child: CachedNetworkImage(
                  imageUrl: emoji.image,
                  errorWidget:
                      (BuildContext context, String url, Object error) {
                    return const SizedBox(
                      child: Center(child: const OBText('?')),
                    );
                  },
                ),
              ),
              title: OBText(emoji.keyword),
            );
          }).toList();

          return Column(
            children: emojiTiles,
          );
        });
  }

  Widget _buildNoResults() {
    return SizedBox(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const OBIcon(OBIcons.sad, customSize: 30.0),
              const SizedBox(
                height: 20.0,
              ),
              OBText(
                'No emoji found matching \'$searchQuery\'.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
