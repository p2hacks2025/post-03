import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AudioPickWidget extends StatefulWidget {
  final Function(File?) onAudioSelected;

  const AudioPickWidget({super.key, required this.onAudioSelected});

  @override
  State<AudioPickWidget> createState() => _AudioPickWidgetState();
}

class _AudioPickWidgetState extends State<AudioPickWidget> {
  File? _audioFile;

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);

    setState(() {
      _audioFile = file;
    });

    widget.onAudioSelected(file);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickAudio,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _audioFile == null
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.audiotrack, size: 48, color: Colors.white54),
                    SizedBox(height: 8),
                    Text('音声ファイルを選択', style: TextStyle(color: Colors.white)),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.music_note,
                      size: 40,
                      color: Colors.cyanAccent,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _audioFile!.path.split('/').last,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
