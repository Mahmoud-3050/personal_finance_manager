import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/receipt_capture_failure.dart';
import '../../domain/entities/receipt_image_source.dart';
import '../../domain/entities/receipt_photo.dart';

const String receiptCaptureDirectoryName = 'receipt-capture';

Directory receiptCaptureFolder({Directory? root}) {
  final Directory base = root ?? Directory.systemTemp;
  return Directory('${base.path}/$receiptCaptureDirectoryName');
}

Future<void> clearLeftoverReceiptPhotos() async {
  final Directory folder = receiptCaptureFolder();
  if (folder.existsSync()) {
    await folder.delete(recursive: true);
  }
}

abstract interface class ReceiptImageDataSource {
  Future<ReceiptPhoto?> pick(ReceiptImageSource source);

  Future<void> delete(ReceiptPhoto photo);
}

class ReceiptImageDataSourceImpl implements ReceiptImageDataSource {
  ReceiptImageDataSourceImpl({
    Future<XFile?> Function(ImageSource source)? pickImage,
    Directory? storageRoot,
  }) : _pickImage = pickImage ?? _pickWithPlugin,
       _storageRoot = storageRoot;

  final Future<XFile?> Function(ImageSource source) _pickImage;
  final Directory? _storageRoot;

  static Future<XFile?> _pickWithPlugin(ImageSource source) {
    return ImagePicker().pickImage(source: source);
  }

  @override
  Future<ReceiptPhoto?> pick(ReceiptImageSource source) async {
    final XFile? picked;
    try {
      picked = await _pickImage(_imageSource(source));
    } on PlatformException {
      throw const CacheException(message: ReceiptCaptureFailure.accessDenied);
    }
    if (picked == null) {
      return null;
    }
    final Directory folder = receiptCaptureFolder(root: _storageRoot);
    if (!folder.existsSync()) {
      await folder.create(recursive: true);
    }
    final File destination = File(
      '${folder.path}/${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await destination.writeAsBytes(await picked.readAsBytes());
    return ReceiptPhoto(path: destination.path);
  }

  @override
  Future<void> delete(ReceiptPhoto photo) async {
    final File file = File(photo.path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  ImageSource _imageSource(ReceiptImageSource source) {
    return switch (source) {
      ReceiptImageSource.camera => ImageSource.camera,
      ReceiptImageSource.gallery => ImageSource.gallery,
    };
  }
}
