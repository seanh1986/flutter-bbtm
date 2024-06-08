import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bbnaf/app/bloc/app_bloc.dart';
import 'package:bbnaf/utils/toast.dart';
import 'package:bbnaf/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:bbnaf/tournament_repository/src/models/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:typed_data';

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
        // height: 60,
        width: 500,
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: [
              SizedBox(height: 30),
              _downloadFileBackup(context),
              SizedBox(height: 30),
              _downloadCoachImportTemplate(context),
              SizedBox(height: 30),
              _downloadNafUploadFile(context),
              SizedBox(height: 30),
              _downloadGlamFile(context),
            ]));
  }

  Widget _downloadCoachImportTemplate(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      style: theme.elevatedButtonTheme.style,
      child: Text('Download Coach Import Template'),
      onPressed: () {
        ToastUtils.show(context, "Downloading Coach Import Template");

        String assetFilePath = 'assets/files/bbtm-coach-import-template.xlsx';
        String downloadFileName = 'bbtm-coach-import-template.xlsx';

        _downloadAssetFile(context, downloadFileName, assetFilePath);
      },
    );
  }

  Widget _downloadFileBackup(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      style: theme.elevatedButtonTheme.style,
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
    );
  }

  Widget _downloadNafUploadFile(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      style: theme.elevatedButtonTheme.style,
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
                  if (value == OkCancelResult.ok) {downloadNafUploadCallback()}
                });
      },
    );
  }

  Widget _downloadGlamFile(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      style: theme.elevatedButtonTheme.style,
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
    );
  }

  Future<void> _downloadAssetFile(BuildContext context, String downloadFileName,
      String assetFilePath) async {
    try {
      // Load file from assets
      final response = await http.get(Uri.parse(assetFilePath));

      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;

        // Create a blob from the bytes
        final blob = html.Blob([bytes]);

        // Create a link element
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', downloadFileName)
          ..click();

        // Cleanup
        html.Url.revokeObjectUrl(url);

        ToastUtils.show(context, "Downloading " + downloadFileName);
      } else {
        throw Exception('Failed to load asset');
      }
    } catch (e) {
      ToastUtils.show(context, "Failed to download " + downloadFileName);
    }
  }
}
