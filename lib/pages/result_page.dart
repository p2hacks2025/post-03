import 'dart:io';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final File audioFile;
  final String effectStyle;

  const ResultPage({
    super.key,
    required this.audioFile,
    required this.effectStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('生成結果')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '選択エフェクト：$effectStyle',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            // 元音声
            Card(
              child: ListTile(
                leading: const Icon(Icons.audiotrack),
                title: const Text('元の音声'),
                subtitle: Text(
                  audioFile.path.split('/').last,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 生成結果（ダミー）
            Card(
              color: Colors.grey.shade100,
              child: const ListTile(
                leading: Icon(Icons.auto_awesome),
                title: Text('生成後の音声'),
                subtitle: Text('キラキラ加工済み（準備中）'),
              ),
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('保存しました（仮）')),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
