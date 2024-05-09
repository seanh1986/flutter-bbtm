import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/home/view/home_page.dart';
import 'package:bbnaf/login/view/login_page.dart';
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
}
