import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/pages/home/lib/poppable_page_controller.dart';
import 'package:Buzzing/widgets/badges/badge.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/nav_bars/themed_nav_bar.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tile_group_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBMainMenuPage extends StatelessWidget {
  final OBMainMenuPageController controller;

  const OBMainMenuPage({this.controller});

  @override
  Widget build(BuildContext context) {
    controller.attach(context: context);
    var buzzingProvider = BuzzingProvider.of(context);
    var localizationService = buzzingProvider.localizationService;
    var intercomService = buzzingProvider.intercomService;
    var userService = buzzingProvider.userService;
    var navigationService = buzzingProvider.navigationService;

    return CupertinoPageScaffold(
      navigationBar: OBThemedNavigationBar(
        title: 'Menu',
      ),
      child: OBPrimaryColorContainer(
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: userService.loggedInUserChange,
              initialData: userService.getLoggedInUser(),
              builder: (BuildContext context,
                  AsyncSnapshot<User> loggedInUserSnapshot) {
                User loggedInUser = loggedInUserSnapshot.data;

                if (loggedInUser == null) return const SizedBox();

                return StreamBuilder(
                  stream: loggedInUserSnapshot.data.updateSubject,
                  initialData: loggedInUserSnapshot.data,
                  builder:
                      (BuildContext context, AsyncSnapshot<User> userSnapshot) {
                    User user = userSnapshot.data;

                    return Expanded(
                        child: ListView(
                      physics: const ClampingScrollPhysics(),
                      // Important: Remove any padding from the ListView.
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        OBTileGroupTitle(
                          title: 'My Openspace',
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.circles),
                          title: const OBText('My circles'),
                          onTap: () {
                            navigationService.navigateToConnectionsCircles(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.lists),
                          title: const OBText('My lists'),
                          onTap: () {
                            navigationService.navigateToFollowsLists(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.followers),
                          title: const OBText('My followers'),
                          onTap: () {
                            navigationService.navigateToFollowersPage(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.following),
                          title: const OBText('My following'),
                          onTap: () {
                            navigationService.navigateToFollowingPage(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.invite),
                          title: const OBText('My invites'),
                          onTap: () {
                            navigationService.navigateToUserInvites(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.communityModerators),
                          title: OBText('My pending moderation tasks'),
                          onTap: () async {
                            await navigationService
                                .navigateToMyModerationTasksPage(
                                    context: context);
                            userService.refreshUser();
                          },
                          trailing: OBBadge(
                            size: 25,
                            count: user.pendingCommunitiesModeratedObjectsCount,
                          ),
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.moderationPenalties),
                          title: OBText('My moderation penalties'),
                          onTap: () async {
                            await navigationService
                                .navigateToMyModerationPenaltiesPage(
                                    context: context);
                            userService.refreshUser();
                          },
                          trailing: OBBadge(
                            size: 25,
                            count: user.activeModerationPenaltiesCount,
                          ),
                        ),
                        OBTileGroupTitle(
                          title: 'App & Account',
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.settings),
                          title: OBText('Settings'),
                          onTap: () {
                            navigationService.navigateToSettingsPage(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.themes),
                          title: OBText('Themes'),
                          onTap: () {
                            navigationService.navigateToThemesPage(
                                context: context);
                          },
                        ),
                        StreamBuilder(
                          stream: userService.loggedInUserChange,
                          initialData: userService.getLoggedInUser(),
                          builder: (BuildContext context,
                              AsyncSnapshot<User> snapshot) {
                            User loggedInUser = snapshot.data;

                            if (loggedInUser == null) return const SizedBox();

                            return ListTile(
                              leading: const OBIcon(OBIcons.help),
                              title: OBText(
                                  localizationService.trans('DRAWER.HELP')),
                              onTap: () async {
                                intercomService.displayMessenger();
                              },
                            );
                          },
                        ),
                        StreamBuilder(
                          stream: userService.loggedInUserChange,
                          initialData: userService.getLoggedInUser(),
                          builder: (BuildContext context,
                              AsyncSnapshot<User> snapshot) {
                            User loggedInUser = snapshot.data;

                            if (loggedInUser == null ||
                                !(loggedInUser.isGlobalModerator ?? false))
                              return const SizedBox();

                            return ListTile(
                              leading: const OBIcon(OBIcons.globalModerator),
                              title: OBText('Global moderation'),
                              onTap: () async {
                                navigationService
                                    .navigateToGlobalModeratedObjects(
                                        context: context);
                              },
                            );
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.link),
                          title: OBText('Useful links'),
                          onTap: () {
                            navigationService.navigateToUsefulLinksPage(
                                context: context);
                          },
                        ),
                        ListTile(
                          leading: const OBIcon(OBIcons.logout),
                          title: OBText(
                              localizationService.trans('DRAWER.LOGOUT')),
                          onTap: () {
                            userService.logout();
                          },
                        )
                      ],
                    ));
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OBMainMenuPageController extends PoppablePageController {}
