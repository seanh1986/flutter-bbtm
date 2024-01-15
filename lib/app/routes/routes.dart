import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/home/view/home_page.dart';
import 'package:bbnaf/login/view/login_page.dart';
import 'package:bbnaf/tournament_selection/view/tournament_creation_page.dart';
import 'package:bbnaf/tournament_selection/view/tournament_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppState state,
  List<Page<dynamic>> pages,
) {
  if (state.authenticationState.status != AuthenticationStatus.authenticated) {
    return [LoginPage.page()];
  }

  return [
    MaterialPage(child: TournamentSelectionPage()),
    // MaterialPage(child: TournamentCreationPage()),
  ];

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
