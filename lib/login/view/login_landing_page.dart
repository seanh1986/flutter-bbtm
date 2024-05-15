import 'package:bbnaf/login/login.dart';
import 'package:bbnaf/login/view/naf_name_login_page.dart';
import 'package:flutter/material.dart';

class LoginLandingPage extends StatelessWidget {
  const LoginLandingPage({super.key});

  static const String tag = "LoginLandingPage";

  static Page<void> page() =>
      const MaterialPage<void>(child: LoginLandingPage());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: const Alignment(0, -1 / 3),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logos/amorical_logo_2024.png',
                  height: 200,
                ),
                const SizedBox(height: 20),
                _NafNameButton(),
                const SizedBox(height: 20),
                _AccountLoginButton(),
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
