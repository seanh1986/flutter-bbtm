import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/login/cubit/naf_name_login_cubit.dart';
import 'package:bbnaf/login/view/naf_name_login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NafNameLoginPage extends StatelessWidget {
  const NafNameLoginPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const NafNameLoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Naf Name Login')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocProvider(
          create: (_) =>
              NafNameLoginCubit(context.read<AuthenticationRepository>()),
          child: const NafNameLoginForm(),
        ),
      ),
    );
  }
}
