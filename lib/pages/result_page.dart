import 'dart:io';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final File originalImage;
  final String illuminationStyle;

  const ResultPage({
    super.key,
    required this.originalImage,
    required this.illuminationStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('生成結果')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'イルミネーション：$illuminationStyle',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Row(
                children: [
                  // Before
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Before'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Image.file(
                            originalImage,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // After（ダミー）
                  Expanded(
                    child: Column(
                      children: [
                        const Text('After'),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Text(
                                '生成結果（準備中）',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('保存しました（仮）')),
                );
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
