import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/home/view/home_page.dart';
import 'package:bbnaf/login/view/login_page.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:bbnaf/tournament_selection/view/tournament_creation_page.dart';
import 'package:bbnaf/tournament_selection/view/tournament_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppState state,
  List<Page<dynamic>> pages,
) {
  switch (state.authenticationState.status) {
    case AuthenticationStatus.authenticated:
      return _authUserRouteByTournamentState(state.tournamentState);
    case AuthenticationStatus.unauthenticated:
      return [LoginPage.page()];
  }

  // if (state.authenticationState.status != AuthenticationStatus.authenticated) {
  //   return [LoginPage.page()];
  // }

  // return [
  //   MaterialPage(child: TournamentSelectionPage()),
  //   // MaterialPage(child: TournamentCreationPage()),
  // ];

  // switch (state.status) {
  //   case AppStatus.selected_tournament:
  //     return [];
  //   // case AppStatus.create_tournament:
  //   //   return [];
  //   case AppStatus.tournament_list:
  //   case AppStatus.authenticated:
  //     return [
  //       MaterialPage(child: TournamentSelectionPage()),
  //       // MaterialPage(child: TournamentCreationPage()),
  //     ];
  //   // return [HomePage.page()];
  //   case AppStatus.unauthenticated:
  //     return [LoginPage.page()];
  //   default:
  //     print("Non-handled AppStatus (!) -> to LoginPage");
  //     return [LoginPage.page()];
  // }
}

List<Page<dynamic>> _authUserRouteByTournamentState(
    TournamentState tournamentState) {
  switch (tournamentState.status) {
    case TournamentStatus.no_tournament_list:
    case TournamentStatus.tournament_list:
    case TournamentStatus.create_tournament:
      return [
        MaterialPage(child: TournamentSelectionPage()),
        // MaterialPage(child: TournamentCreationPage()),
      ];
    case TournamentStatus.selected_tournament:
      return [
        MaterialPage(child: HomePage()),
      ];
  }
}
