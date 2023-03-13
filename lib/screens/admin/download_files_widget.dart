import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/blocs/tournament/tournament_bloc_event_state.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/models/tournament/tournament.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DownloadFilesWidget extends StatefulWidget {
  final Tournament tournament;
  final TournamentBloc tournyBloc;

  DownloadFilesWidget(
      {Key? key, required this.tournament, required this.tournyBloc})
      : super(key: key);

  @override
  State<DownloadFilesWidget> createState() {
    return _DownloadFilesWidget();
  }
}

class _DownloadFilesWidget extends State<DownloadFilesWidget> {
  late TournamentBloc _tournyBloc;

  late FToast fToast;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);

    _tournyBloc = BlocProvider.of<TournamentBloc>(context);
  }

  @override
  void dispose() {
    _tournyBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TitleBar(title: "Download Files"),
      SizedBox(height: 20),
      _downloadFileBtns(context)
    ]);
  }

  Widget _downloadFileBtns(BuildContext context) {
    return Container(
        height: 60,
        padding: EdgeInsets.all(10),
        child: ListView(scrollDirection: Axis.horizontal, children: [
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
              ToastUtils.show(fToast, "Downloading Backup File");

              bool success = await _tournyBloc.downloadTournamentBackup(
                  DownloadTournamentBackup(widget.tournament));

              if (success) {
                ToastUtils.showSuccess(
                    fToast, "Backup successfully downloaded");
              } else {
                ToastUtils.showFailed(fToast, "Backup failed to download");
              }
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
              ToastUtils.show(fToast, "Downloading Naf Upload File");

              bool success =
                  await _tournyBloc.downloadNafUploadFile(widget.tournament);

              if (success) {
                ToastUtils.showSuccess(fToast, "Naf Upload downloaded");
              } else {
                ToastUtils.showFailed(fToast, "Naf Upload failed to download");
              }
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
              ToastUtils.show(fToast, "Downloading Glam File");

              bool success =
                  await _tournyBloc.downloadGlamFile(widget.tournament);

              if (success) {
                ToastUtils.showSuccess(fToast, "Glam downloaded");
              } else {
                ToastUtils.showFailed(fToast, "Glam failed to download");
              }
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
