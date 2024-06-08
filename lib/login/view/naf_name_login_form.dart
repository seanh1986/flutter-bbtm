import 'package:bbnaf/login/cubit/naf_name_login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class NafNameLoginForm extends StatelessWidget {
  const NafNameLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NafNameLoginCubit, NafNameLoginState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pop();
        } else if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                  content:
                      Text(state.errorMessage ?? 'Naf Name Log In Failure')),
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
                'assets/images/logos/BBTM-Cover-Photo-Thick.png',
              ),
              const SizedBox(height: 40),
              _NafNameInput(),
              const SizedBox(height: 8),
              _NafNameLoginButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NafNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NafNameLoginCubit, NafNameLoginState>(
      buildWhen: (previous, current) => previous.nafName != current.nafName,
      builder: (context, state) {
        return TextField(
          key: const Key('nafNameLogInForm_nafNameInput_textField'),
          onChanged: (nafName) =>
              context.read<NafNameLoginCubit>().nafNameChanged(nafName),
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

class _NafNameLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NafNameLoginCubit, NafNameLoginState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('nafNameLogInForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.orangeAccent,
                ),
                onPressed: state.isValid
                    ? () => context
                        .read<NafNameLoginCubit>()
                        .nafNameSignInSubmitted()
                    : null,
                child: const Text('NAF NAME LOG IN'),
              );
      },
    );
  }
}
