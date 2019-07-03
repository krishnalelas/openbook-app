import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/widgets/alerts/button_alert.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:flutter/material.dart';

class OBProfileNoPosts extends StatelessWidget {
  final User user;
  final VoidCallback onWantsToRefreshProfile;

  OBProfileNoPosts(this.user, {@required this.onWantsToRefreshProfile});

  @override
  Widget build(BuildContext context) {
    UserService _userService = BuzzingProvider.of(context).userService;
    bool isLoggedInUser = _userService.isLoggedInUser(user);
    String name = user.getProfileName();

    return OBButtonAlert(
      text: isLoggedInUser ? 'You have not shared anything yet.': '$name has not shared anything yet.',
      onPressed: onWantsToRefreshProfile,
      buttonText: 'Refresh',
      buttonIcon: OBIcons.refresh,
      assetImage: 'assets/images/stickers/perplexed-owl.png',
    );
  }
}
