import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/home/view/home_page.dart';
import 'package:bbnaf/login/view/login_page.dart';
import 'package:bbnaf/sign_up/sign_up.dart';
import 'package:bbnaf/tournament_selection/view/tournament_creation_page.dart';
import 'package:bbnaf/tournament_selection/view/tournament_selection_page.dart';
import 'package:flutter/material.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppState state,
  List<Page<dynamic>> pages,
) {
  switch (state.screenState.mainScreen) {
    case LoginPage.tag:
      return [LoginPage.page()];
    // case SignUpPage.tag:
    //   return [SignUpPage.page()];
    case TournamentSelectionPage.tag:
      if (state.tournamentState.status == TournamentStatus.create_tournament) {
        return [MaterialPage(child: TournamentCreationPage())];
      } else {
        return [MaterialPage(child: TournamentSelectionPage())];
      }
    case HomePage.tag:
      return [MaterialPage(child: HomePage())];
  }

  return [];

  // switch (state.authenticationState.status) {
  //   case AuthenticationStatus.authenticated:
  //     return _authUserRouteByTournamentState(state.tournamentState);
  //   case AuthenticationStatus.unauthenticated:
  //     return [LoginPage.page()];
  // }
}

// List<Page<dynamic>> _authUserRouteByTournamentState(
//     TournamentState tournamentState) {
//   switch (tournamentState.status) {
//     case TournamentStatus.no_tournament_list:
//     case TournamentStatus.tournament_list:
//       return [MaterialPage(child: TournamentSelectionPage())];
//     case TournamentStatus.create_tournament:
//       return [MaterialPage(child: TournamentCreationPage())];
//     case TournamentStatus.selected_tournament:
//       return [MaterialPage(child: HomePage())];
//   }
// }
