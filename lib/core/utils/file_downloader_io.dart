import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadCsvFile(String csvContent, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsString(csvContent);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path)],
      text: 'ShopSync CSV Report',
    ),
  );
}
