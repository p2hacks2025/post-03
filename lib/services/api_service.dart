import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000';

  static Future<File> uploadAudio({
    required File audioFile,
    required String style,
  }) async {
    final uri = Uri.parse('$_baseUrl/process');

    final request = http.MultipartRequest('POST', uri)
      ..fields['style'] = style
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
        ),
      );

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Upload failed');
    }

    // 🔽 ここが重要：バイナリとして受け取る
    final bytes = await response.stream.toBytes();

    // 保存先
    final dir = await getTemporaryDirectory();
    final outputFile = File(
      path.join(dir.path, 'processed_${DateTime.now().millisecondsSinceEpoch}.wav'),
    );

    await outputFile.writeAsBytes(bytes);

    return outputFile;
  }
}
