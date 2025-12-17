import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ResultPage extends StatefulWidget {
  final File originalAudio;
  final File processedAudio;
  final String effectStyle;

  const ResultPage({
    super.key,
    required this.originalAudio,
    required this.processedAudio,
    required this.effectStyle,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final AudioPlayer _player = AudioPlayer();
  File? _current;
  bool _isPlaying = false;

  Future<void> _play(File file) async {
    if (_isPlaying) {
      await _player.stop();
    }

    await _player.play(DeviceFileSource(file.path));

    setState(() {
      _current = file;
      _isPlaying = true;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

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
              '選択エフェクト：${widget.effectStyle}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            // 元音声
            Card(
              child: ListTile(
                leading: const Icon(Icons.audiotrack),
                title: const Text('元の音声'),
                subtitle: Text(widget.originalAudio.path.split('/').last),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _play(widget.originalAudio),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 生成後音声
            Card(
              color: Colors.purple.shade50,
              child: ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('生成後の音声'),
                subtitle: Text(widget.processedAudio.path.split('/').last),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () => _play(widget.processedAudio),
                ),
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
