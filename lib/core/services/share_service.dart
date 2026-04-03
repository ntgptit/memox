import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

abstract interface class ShareService {
  Future<void> shareJson({
    required String content,
    required String fileName,
    String? subject,
  });

  Future<void> shareText(String value);
}

final class PlatformShareService implements ShareService {
  const PlatformShareService();

  @override
  Future<void> shareJson({
    required String content,
    required String fileName,
    String? subject,
  }) async {
    await Share.shareXFiles(
      <XFile>[
        XFile.fromData(
          Uint8List.fromList(utf8.encode(content)),
          mimeType: 'application/json',
          name: fileName,
        ),
      ],
      subject: subject,
      fileNameOverrides: <String>[fileName],
    );
  }

  @override
  Future<void> shareText(String value) async {
    await Share.share(value);
  }
}

final class NoopShareService implements ShareService {
  const NoopShareService();

  @override
  Future<void> shareJson({
    required String content,
    required String fileName,
    String? subject,
  }) async {}

  @override
  Future<void> shareText(String value) async {}
}
