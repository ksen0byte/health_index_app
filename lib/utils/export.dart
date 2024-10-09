import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';

Future<FileSaveLocation?> chooseSaveLocation(String baseName) async {
  padded(int num) => num.toString().padLeft(2, '0');

  var dateTime = DateTime.now();
  String formattedDate =
      "${padded(dateTime.day)}-${padded(dateTime.month)}-${dateTime.year}_${padded(dateTime.hour)}-${padded(dateTime.minute)}-${padded(dateTime.second)}";

  final FileSaveLocation? fileSaveLocation = await getSaveLocation(
    initialDirectory: (await getApplicationDocumentsDirectory()).path,
    suggestedName: '${baseName}_$formattedDate.csv',
  );
  if (fileSaveLocation == null) {
    // Operation was canceled by the user.
    return Future.value(null);
  }

  return Future.value(fileSaveLocation);
}

Future<void> saveCsv(FileSaveLocation fileSaveLocation, String csvData) async {
  final XFile textFile = XFile.fromData(
    Uint8List.fromList(utf8.encode(csvData)),
    mimeType: 'text/csv',
  );

  await textFile.saveTo(fileSaveLocation.path);
}
