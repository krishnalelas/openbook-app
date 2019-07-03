import 'package:Buzzing/pages/auth/create_account/blocs/create_account.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/localization.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/buttons/success_button.dart';
import 'package:flutter/material.dart';

class OBAuthDonePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OBAuthDonePageState();
  }
}

class OBAuthDonePageState extends State<OBAuthDonePage> {
  LocalizationService localizationService;
  CreateAccountBloc createAccountBloc;

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    localizationService = buzzingProvider.localizationService;
    createAccountBloc = buzzingProvider.createAccountBloc;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                colorFilter: new ColorFilter.mode(
                    Colors.white.withOpacity(0.1), BlendMode.dstATop),
                image: new AssetImage('assets/images/confetti-background.gif'),
                fit: BoxFit.cover)),
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(child: SingleChildScrollView(child: _buildHooray())),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0.0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: _buildNextButton(context: context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHooray() {
    var title = localizationService.trans('AUTH.CREATE_ACC.DONE_TITLE');

    String username = createAccountBloc.getUsername();

    return Column(
      children: <Widget>[
        Text(
          '🐣‍',
          style: TextStyle(fontSize: 45.0, color: Colors.white),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              //color: Colors.white
            )),
        const SizedBox(
          height: 20.0,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: 'Your account has been created with username '),
                TextSpan(
                    text: '@$username',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '.')
              ]),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Text('You can change this in your profile settings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16
                //color: Colors.white
                )),
      ],
    );
  }

  Widget _buildNextButton({@required BuildContext context}) {
    String buttonText =
        localizationService.trans('AUTH.CREATE_ACC.DONE_CONTINUE');

    return OBSuccessButton(
      minWidth: double.infinity,
      size: OBButtonSize.large,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            buttonText,
            style: TextStyle(fontSize: 18.0),
          )
        ],
      ),
      onPressed: () {
        Navigator.popUntil(context, ModalRoute.withName('/auth/get-started'));
        Navigator.pushReplacementNamed(context, '/');
      },
    );
  }
}
