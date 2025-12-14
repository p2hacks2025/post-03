import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/file_pic_widget.dart';
import '../widgets/loading_dialog.dart';
import 'result_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedAudio;
  String _selectedStyle = 'シンプル';

  Future<void> _executeSimulation() async {
    if (_selectedAudio == null) return;

    LoadingDialog.show(context);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    LoadingDialog.hide(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(
          audioFile: _selectedAudio!,
          effectStyle: _selectedStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('キラキラ音声シミュレーション')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AudioPickWidget(
              onAudioSelected: (file) {
                setState(() {
                  _selectedAudio = file;
                });
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Text('エフェクト：'),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedStyle,
                  items: const [
                    DropdownMenuItem(value: 'シンプル', child: Text('シンプル')),
                    DropdownMenuItem(value: 'キラキラ', child: Text('キラキラ')),
                    DropdownMenuItem(value: 'ナイト', child: Text('ナイト')),
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
              onPressed: _selectedAudio == null ? null : _executeSimulation,
              child: const Text('実行'),
            ),
          ],
        ),
      ),
    );
  }
}
