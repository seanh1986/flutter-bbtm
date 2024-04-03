import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadFilesWidget extends StatefulWidget {
  DownloadFilesWidget({Key? key}) : super(key: key);

  @override
  State<DownloadFilesWidget> createState() {
    return _DownloadFilesWidget();
  }
}

class _DownloadFilesWidget extends State<DownloadFilesWidget> {
  late Tournament _tournament;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppState appState = context.select((AppBloc bloc) => bloc.state);
    _tournament = appState.tournamentState.tournament;

    return Column(children: [
      TitleBar(title: "Download Files"),
      SizedBox(height: 20),
      _downloadFileBtns(context)
    ]);
  }

  Widget _downloadFileBtns(BuildContext context) {
    return Container(
        height: 60,
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              SizedBox(width: 20),
              _downloadFileBackup(context),
              SizedBox(width: 20),
              _downloadNafUploadFile(context),
              SizedBox(width: 20),
              _downloadGlamFile(context),
            ]));
  }

  Widget _downloadFileBackup(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Download Backup'),
          onPressed: () {
            VoidCallback downloadBackupCallback = () async {
              ToastUtils.show(context, "Downloading Backup File");

              context.read<AppBloc>().add(DownloadBackup(_tournament));
            };

            showOkCancelAlertDialog(
                    context: context,
                    title: "Download Backup File",
                    message:
                        "This will download a backup file which can be used as a backup to restore at a later time",
                    okLabel: "Download",
                    cancelLabel: "Cancel")
                .then((value) => {
                      if (value == OkCancelResult.ok) {downloadBackupCallback()}
                    });
          },
        ));
  }

  Widget _downloadNafUploadFile(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Download Naf Upload'),
          onPressed: () {
            VoidCallback downloadNafUploadCallback = () async {
              ToastUtils.show(context, "Downloading Naf Upload File");

              context.read<AppBloc>().add(DownloadNafUploadFile(_tournament));
            };

            showOkCancelAlertDialog(
                    context: context,
                    title: "Download Naf Upload File",
                    message:
                        "This will download a the naf upload file which can be used to upload tournament results",
                    okLabel: "Download",
                    cancelLabel: "Cancel")
                .then((value) => {
                      if (value == OkCancelResult.ok)
                        {downloadNafUploadCallback()}
                    });
          },
        ));
  }

  Widget _downloadGlamFile(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Download Glam Upload File'),
          onPressed: () {
            VoidCallback downloadGlamCallback = () async {
              ToastUtils.show(context, "Downloading Glam File");

              context.read<AppBloc>().add(DownloadGlamFile(_tournament));
            };

            showOkCancelAlertDialog(
                    context: context,
                    title: "Glam Upload File",
                    message:
                        "This will download a the file which can be used to upload Glam results",
                    okLabel: "Download",
                    cancelLabel: "Cancel")
                .then((value) => {
                      if (value == OkCancelResult.ok) {downloadGlamCallback()}
                    });
          },
        ));
  }
}
