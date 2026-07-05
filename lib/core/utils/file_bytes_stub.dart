import 'dart:typed_data';

Future<Uint8List> readFileBytes(String path) async {
  throw UnsupportedError('Reading local files by path is not supported on the web.');
}
