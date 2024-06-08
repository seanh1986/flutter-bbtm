import 'package:bbnaf/login/cubit/spectator_login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class SpectatorLoginForm extends StatelessWidget {
  const SpectatorLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpectatorLoginCubit, SpectatorLoginState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pop();
        } else if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content:
                      Text(state.errorMessage ?? 'Spectator Log In Failure')),
            );
        }
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logos/BBTM-Cover-Photo.png',
              ),
              const SizedBox(height: 40),
              _SpectatorLoginButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpectatorLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpectatorLoginCubit, SpectatorLoginState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('spectatorLogInForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.orangeAccent,
                ),
                onPressed: () => context
                    .read<SpectatorLoginCubit>()
                    .spectatorSignInSubmitted(),
                child: const Text('START SPECTATING'),
              );
      },
    );
  }
}
