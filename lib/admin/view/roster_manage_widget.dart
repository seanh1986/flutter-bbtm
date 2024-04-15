import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RosterManageWidget extends StatefulWidget {
  RosterManageWidget({Key? key}) : super(key: key);

  @override
  State<RosterManageWidget> createState() {
    return _RosterManageWidget();
  }
}

enum RosterDownloadState {
  Uploaded,
  NotUploaded,
  Checking,
}

class _RosterManageWidget extends State<RosterManageWidget> {
  late Map<String, RosterDownloadState> _rosterDownloads = {};

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    Tournament tournament = appState.tournamentState.tournament;
    initFromTournament(context, tournament);

    return _getCurrentStatus(context);
  }

  Widget _getCurrentStatus(BuildContext context) {
    return Column(children: [
      SizedBox(height: 10),
      _getCoachesByRosterState(context, RosterDownloadState.Uploaded),
      SizedBox(height: 5),
      Divider(),
      SizedBox(height: 5),
      _getCoachesByRosterState(context, RosterDownloadState.NotUploaded),
      SizedBox(height: 5),
      Divider(),
      SizedBox(height: 5),
      _getCoachesByRosterState(context, RosterDownloadState.Checking),
      SizedBox(height: 10),
    ]);
  }

  Widget _getCoachesByRosterState(
      BuildContext context, RosterDownloadState state) {
    final theme = Theme.of(context);

    Widget title = Text(state.name, style: theme.textTheme.headlineSmall);

    List<String> nafNames = _rosterDownloads.entries
        .where((a) => a.value == state)
        .map((e) => e.key)
        .toList();

    String msg;
    if (nafNames.isEmpty) {
      msg = "None";
    } else {
      msg = nafNames.join(", ");
    }

    return Column(
      children: [
        title,
        SizedBox(
          height: 10,
        ),
        Text(msg, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  void initFromTournament(BuildContext context, Tournament tournament) {
    List<Coach> coaches = tournament.getCoaches();

    coaches.forEach((c) {
      bool noFile = c.rosterFileName.isEmpty;

      if (noFile) {
        _rosterDownloads.update(
            c.nafName, (v) => RosterDownloadState.NotUploaded,
            ifAbsent: () => RosterDownloadState.NotUploaded);

        return;
      }

      RosterDownloadState? state = _rosterDownloads[c.nafName];

      if (state == null) {
        _rosterDownloads.putIfAbsent(
            c.nafName, () => RosterDownloadState.Checking);

        context.read<AppBloc>().getFileUrl(c.rosterFileName).then((value) {
          if (mounted) {
            bool isUploaded = value.isNotEmpty;
            RosterDownloadState state = isUploaded
                ? RosterDownloadState.Uploaded
                : RosterDownloadState.NotUploaded;

            setState(() {
              _rosterDownloads.update(c.nafName, (v) => state,
                  ifAbsent: () => state);
            });
          }
        }).onError((error, stackTrace) {
          setState(() {
            _rosterDownloads.update(
                c.nafName, (v) => RosterDownloadState.NotUploaded,
                ifAbsent: () => RosterDownloadState.NotUploaded);
          });
        });
        return;
      } else {
        _rosterDownloads.update(c.nafName, (v) => state, ifAbsent: () => state);
      }
    });
  }
}
