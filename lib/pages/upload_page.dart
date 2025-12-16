import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/file_pic_widget.dart';
import '../widgets/loading_dialog.dart';
import '../services/api_service.dart';
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

  try {
    final result = await ApiService.uploadAudio(
      audioFile: _selectedAudio!,
      style: _selectedStyle,
    );

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

  } catch (e) {
    if (!mounted) return;
    LoadingDialog.hide(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('エラー: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KiraStar',
      style: TextStyle(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w700,
        fontSize: 22,
        letterSpacing: 1.2,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 12,
            color: Colors.cyanAccent,
            offset: Offset(0, 0),
          ),
        ],
      ),),
        backgroundColor: const Color(0xFF1A0033), // ダークネオン系
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8E2DE2), // ネオンパープル
              Color(0xFF4A00E0), // ディープパープル
              Color(0xFF00C6FF), // ネオンシアン
            ],
          ),
        ),
        child: Padding(
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
                  const Text('エフェクト：', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _selectedStyle,
                    dropdownColor: const Color(0xFF2A004F),
                    style: const TextStyle(color: Colors.white),
                    underline: Container(height: 2, color: Colors.cyanAccent),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2EDF), // ネオンピンク
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selectedAudio == null ? null : _executeSimulation,
                child: const Text(
                  '実行',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold ,color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
