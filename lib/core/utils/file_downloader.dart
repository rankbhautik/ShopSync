import 'file_downloader_stub.dart'
    if (dart.library.html) 'file_downloader_web.dart'
    if (dart.library.io) 'file_downloader_io.dart' as downloader;

Future<void> exportCsvFile(String csvContent, String fileName) async {
  await downloader.downloadCsvFile(csvContent, fileName);
}
