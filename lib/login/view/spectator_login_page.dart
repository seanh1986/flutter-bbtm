import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/login/cubit/spectator_login_cubit.dart';
import 'package:bbnaf/login/view/spectator_login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpectatorLoginPage extends StatelessWidget {
  const SpectatorLoginPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SpectatorLoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spectator Login')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocProvider(
          create: (_) =>
              SpectatorLoginCubit(context.read<AuthenticationRepository>()),
          child: const SpectatorLoginForm(),
        ),
      ),
    );
  }
}
