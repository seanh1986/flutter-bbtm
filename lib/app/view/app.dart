import 'package:authentication_repository/authentication_repository.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/app/routes/routes.dart';
import 'package:bbnaf/theme.dart';
import 'package:bbnaf/tournament_repository/src/tournament_repository.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({
    required AuthenticationRepository authenticationRepository,
    required TournamentRepository tournamentRepository,
    super.key,
  })  : _authenticationRepository = authenticationRepository,
        _tournamentRepository = tournamentRepository;

  final AuthenticationRepository _authenticationRepository;
  final TournamentRepository _tournamentRepository;

  @override
  Widget build(BuildContext context) {
    print("App -> Build!");

    return RepositoryProvider.value(
      value: _authenticationRepository,
      child: BlocProvider(
        create: (_) => AppBloc(
            authenticationRepository: _authenticationRepository,
            tournamentRepository: _tournamentRepository),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "BB Tournament Manager",
      theme: getAppTheme(context, false),
      darkTheme: getAppTheme(context, true),
      themeMode: ThemeMode.system,
      home: FlowBuilder<AppState>(
        state: context.select((AppBloc bloc) => bloc.state),
        onGeneratePages: onGenerateAppViewPages,
      ),
    );
  }
}
