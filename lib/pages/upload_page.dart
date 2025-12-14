import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/image_pic_widget.dart';
import '../widgets/loading_dialog.dart';
import 'result_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedImage;
  String _selectedStyle = 'シンプル';

  Future<void> _executeSimulation() async {
    LoadingDialog.show(context);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 必ず先にロードを閉じる
    LoadingDialog.hide(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(
          originalImage: _selectedImage!,
          illuminationStyle: _selectedStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('イルミネーションシミュレーション')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ImagePickWidget(
              onImageSelected: (file) {
                setState(() {
                  _selectedImage = file;
                });
              },
            ),

            const SizedBox(height: 16),

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

            const Spacer(),

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
