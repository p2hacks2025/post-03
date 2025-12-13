import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedImage;
  String _selectedStyle = 'シンプル';

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _executeSimulation() {
    // ここではまだ Python API には送らない
    // 次のステップで実装予定

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('実行内容確認'),
        content: Text('画像: 選択済み\nイルミネーション: $_selectedStyle'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('イルミネーションシミュレーション')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 画像プレビュー領域
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage == null
                    ? const Center(child: Text('木の画像をアップロードしてください'))
                    : Image.file(_selectedImage!, fit: BoxFit.contain),
              ),
            ),

            const SizedBox(height: 16),

            // 画像選択ボタン
            ElevatedButton(onPressed: _pickImage, child: const Text('画像を選択')),

            const SizedBox(height: 16),

            // イルミネーション選択
            Row(
              children: [
                const Text('イルミネーション：'),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedStyle,
                  items: const [
                    DropdownMenuItem(value: 'シンプル', child: Text('シンプル')),
                    DropdownMenuItem(value: 'カラフル', child: Text('カラフル')),
                    DropdownMenuItem(value: '冬色', child: Text('冬色')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStyle = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 実行ボタン
            ElevatedButton(
              onPressed: _selectedImage == null ? null : _executeSimulation,
              child: const Text('実行'),
            ),
          ],
        ),
      ),
    );
  }
}
