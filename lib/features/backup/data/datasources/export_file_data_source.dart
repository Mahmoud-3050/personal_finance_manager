import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/error/exceptions.dart';
import '../models/book_snapshot_model.dart';

abstract interface class ExportFileDataSource {
  Future<void> share(BookSnapshotModel snapshot);

  Future<BookSnapshotModel> pick();
}

class DeviceExportFileDataSource implements ExportFileDataSource {
  @override
  Future<void> share(BookSnapshotModel snapshot) async {
    final Directory directory = await getTemporaryDirectory();
    final File file = File('${directory.path}/finance-export.json');
    await file.writeAsString(snapshot.encode());
    await SharePlus.instance.share(
      ShareParams(files: <XFile>[XFile(file.path)]),
    );
  }

  @override
  Future<BookSnapshotModel> pick() async {
    final PlatformFile? file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const <String>['json'],
    );
    if (file == null) {
      throw const RequestCancelledException();
    }
    return BookSnapshotModel.decode(utf8.decode(await file.readAsBytes()));
  }
}
