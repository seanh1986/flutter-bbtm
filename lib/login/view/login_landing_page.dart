import 'package:bbnaf/login/login.dart';
import 'package:bbnaf/login/view/bbtm_logo.dart';
import 'package:bbnaf/login/view/naf_name_login_page.dart';
import 'package:bbnaf/login/view/spectator_login_page.dart';
import 'package:bbnaf/utils/buy_me_a_coffee/buy_me_a_coffee.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginLandingPage extends StatelessWidget {
  const LoginLandingPage({super.key});

  static const String tag = "LoginLandingPage";

  static Page<void> page() =>
      const MaterialPage<void>(child: LoginLandingPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BbtmLogo(),
                const SizedBox(height: 40),
                _NafNameButton(),
                const SizedBox(height: 20),
                _AccountLoginButton(),
                const SizedBox(height: 20),
                _SpectatorButton(),
                const SizedBox(height: 40),
                Divider(),
                const SizedBox(height: 40),
                Container(
                  height: 40,
                  child: BuyMeACoffeeWidget(
                    sponsorID: "seanhuberman",
                    theme: BlueTheme(),
                    textStyle: GoogleFonts.cookie(
                        color: Colors.black,
                        textStyle: TextStyle(fontSize: 16.0)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      style: theme.elevatedButtonTheme.style,
      key: const Key('loginLandingPage_accountLogin_flatButton'),
      onPressed: () => Navigator.of(context).push<void>(LoginPage.route()),
      child: Text('ACCOUNT LOGIN'),
    );
  }
}

class _NafNameButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      style: theme.elevatedButtonTheme.style,
      key: const Key('loginLandingPage_nafNameLogin_flatButton'),
      onPressed: () =>
          Navigator.of(context).push<void>(NafNameLoginPage.route()),
      child: Text('NAF NAME LOGIN'),
    );
  }
}

class _SpectatorButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      style: theme.elevatedButtonTheme.style,
      key: const Key('loginLandingPage_spectatorLogin_flatButton'),
      onPressed: () =>
          Navigator.of(context).push<void>(SpectatorLoginPage.route()),
      child: Text('SPECTATOR'),
    );
  }
}
