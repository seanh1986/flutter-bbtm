import 'package:bbnaf/login/cubit/guest_login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class GuestLoginForm extends StatelessWidget {
  const GuestLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestLoginCubit, GuestLoginState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pop();
        } else if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content: Text(state.errorMessage ?? 'Guest Log In Failure')),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NafNameInput(),
            const SizedBox(height: 8),
            _GuestLoginButton(),
          ],
        ),
      ),
    );
  }
}

class _NafNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuestLoginCubit, GuestLoginState>(
      buildWhen: (previous, current) => previous.nafName != current.nafName,
      builder: (context, state) {
        return TextField(
          key: const Key('guestLogInForm_nafNameInput_textField'),
          onChanged: (nafName) =>
              context.read<GuestLoginCubit>().nafNameChanged(nafName),
          decoration: InputDecoration(
            labelText: 'naf name',
            helperText: '',
            errorText: null,
          ),
        );
      },
    );
  }
}

class _GuestLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuestLoginCubit, GuestLoginState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('guestLogInForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.orangeAccent,
                ),
                onPressed: state.isValid
                    ? () =>
                        context.read<GuestLoginCubit>().guestSignInSubmitted()
                    : null,
                child: const Text('GUEST LOG IN'),
              );
      },
    );
  }
}
