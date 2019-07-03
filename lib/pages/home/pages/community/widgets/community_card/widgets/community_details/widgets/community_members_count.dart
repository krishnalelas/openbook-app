import 'package:Buzzing/libs/pretty_count.dart';
import 'package:Buzzing/models/theme.dart';
import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/provider.dart';
import 'package:flutter/material.dart';

class OBCommunityMembersCount extends StatelessWidget {
  final Community community;

  OBCommunityMembersCount(this.community);

  @override
  Widget build(BuildContext context) {
    int membersCount = community.membersCount;

    if (membersCount == null || membersCount == 0) return const SizedBox();

    String count = getPrettyCount(membersCount);

    String userAdjective = community.userAdjective ?? 'Member';
    String usersAdjective = community.usersAdjective ?? 'Members';

    var buzzingProvider = BuzzingProvider.of(context);
    var themeService = buzzingProvider.themeService;
    var themeValueParserService = buzzingProvider.themeValueParserService;
    var userService = buzzingProvider.userService;
    var navigationService = buzzingProvider.navigationService;

    return StreamBuilder(
        stream: themeService.themeChange,
        initialData: themeService.getActiveTheme(),
        builder: (BuildContext context, AsyncSnapshot<OBTheme> snapshot) {
          var theme = snapshot.data;

          return GestureDetector(
            onTap: () {
              bool isPublicCommunity = community.isPublic();
              bool isLoggedInUserMember =
                  community.isMember(userService.getLoggedInUser());

              if (isPublicCommunity || isLoggedInUserMember) {
                navigationService.navigateToCommunityMembers(
                    community: community, context: context);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: count,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeValueParserService
                                .parseColor(theme.primaryTextColor))),
                    TextSpan(text: ' '),
                    TextSpan(
                        text:
                            membersCount == 1 ? userAdjective : usersAdjective,
                        style: TextStyle(
                            fontSize: 16,
                            color: themeValueParserService
                                .parseColor(theme.secondaryTextColor)))
                  ])),
                ),
              ],
            ),
          );
        });
  }
}
