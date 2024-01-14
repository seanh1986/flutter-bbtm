import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/home/view/home_page.dart';
import 'package:bbnaf/login/view/login_page.dart';
import 'package:flutter/widgets.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.selected_tournament:
      return [];
    case AppStatus.create_tournament:
      return [];
    case AppStatus.tournament_list:
      return [];
    case AppStatus.authenticated:
      return [HomePage.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
    default:
      print("Non-handled AppStatus (!) -> to LoginPage");
      return [LoginPage.page()];
  }
}
