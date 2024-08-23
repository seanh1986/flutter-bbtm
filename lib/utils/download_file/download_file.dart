import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:async';
import 'dart:io';

class DownloadFileUtils {
  static Future<bool> downloadFile(String url, String fileName) async {
    String? taskId = null;

    if (kIsWeb) {
      // Web platform
      taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: '', // Web does not need savedDir
        fileName: fileName,
        showNotification: false, // Web does not support notifications
        openFileFromNotification: false, // Web does not support notifications
      );
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Mobile platforms
      taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir:
            '/storage/emulated/0/Download', // Default download folder for Android
        fileName: fileName,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Desktop platforms
      taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: '', // Change to the path where you want to save files
        fileName: fileName,
        showNotification: true, // show download progress in status bar
        openFileFromNotification:
            true, // click on notification to open downloaded file
      );
    } else {
      print("Unsupported platform");
    }

    return taskId != null;
  }
}
