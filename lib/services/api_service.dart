import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // FastAPI サーバーのベース URL
  // Android エミュレータでは 10.0.2.2 がホスト PC の localhost に相当
  // static const String _baseUrl = 'http://10.0.2.2:8000';
  static const String _baseUrl = 'http://127.0.0.1:8000';

  // 音声ファイルをサーバーにアップロードする関数
  static Future<Map<String, dynamic>> uploadAudio({
    required File audioFile, // アップロードする音声ファイル
    required String style,   // エフェクトの種類などの文字列
  }) async {
    print("Sending file: ${audioFile.path} with style: $style"); // ←追加
    // FastAPI のエンドポイント URI を作成
    final uri = Uri.parse('$_baseUrl/process');

    // Multipart リクエストの作成
    final request = http.MultipartRequest('POST', uri)
      ..fields['style'] = style // フォームデータとして style を送信
      ..files.add(
        // ファイルフィールドを追加
        // 'file' の名前は FastAPI 側のパラメータ名と一致させる必要あり
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
        ),
      );

    // リクエスト送信
    final response = await request.send();
    print("HTTP status: ${response.statusCode}"); // ←追加

    // レスポンスを文字列として取得
    final responseBody = await response.stream.bytesToString();
    print("Response body: $responseBody"); // ←追加

    // ステータスコードが 200 以外なら例外を投げる
    if (response.statusCode != 200) {
      throw Exception('Upload failed: $responseBody');
    }

    // JSON をデコードして Map として返す
    return jsonDecode(responseBody);
  }
}