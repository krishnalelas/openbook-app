import 'package:Buzzing/models/user.dart';
import 'package:Buzzing/pages/home/lib/poppable_page_controller.dart';
import 'package:Buzzing/pages/home/pages/profile/profile.dart';
import 'package:Buzzing/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBOwnProfilePage extends StatefulWidget {
  final OBOwnProfilePageController controller;

  OBOwnProfilePage({
    this.controller,
  });

  @override
  State<StatefulWidget> createState() {
    return OBOwnProfilePageState();
  }
}

class OBOwnProfilePageState extends State<OBOwnProfilePage> {
  OBProfilePageController _profilePageController;

  @override
  void initState() {
    super.initState();
    _profilePageController = OBProfilePageController();
    if (widget.controller != null)
      widget.controller.attach(context: context, state: this);
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    var userService = buzzingProvider.userService;

    return StreamBuilder(
      stream: userService.loggedInUserChange,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        var data = snapshot.data;
        if (data == null) return const SizedBox();
        return OBProfilePage(
          data,
          controller: _profilePageController,
        );
      },
    );
  }

  void scrollToTop() {
    _profilePageController.scrollToTop();
  }
}

class OBOwnProfilePageController extends PoppablePageController {
  OBOwnProfilePageState _state;

  void attach({@required BuildContext context, OBOwnProfilePageState state}) {
    super.attach(context: context);
    _state = state;
  }

  void scrollToTop() {
    if (_state != null) _state.scrollToTop();
  }
}
