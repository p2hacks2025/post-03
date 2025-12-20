import 'dart:io';
import 'dart:ui';
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

class _UploadPageState extends State<UploadPage>
    with SingleTickerProviderStateMixin {
  File? _selectedAudio;
  String _selectedStyle = 'シンプル';

  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  Future<void> _executeSimulation() async {
    if (_selectedAudio == null) return;

    LoadingDialog.show(context);

    try {
      final File processedAudio = await ApiService.uploadAudio(
        audioFile: _selectedAudio!,
        style: _selectedStyle,
      );

      if (!mounted) return;
      LoadingDialog.hide(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            originalAudio: _selectedAudio!,
            processedAudio: processedAudio,
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
        backgroundColor: const Color(0xFF1A0033),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _shineController,
          builder: (_, __) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Crestarl',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.8,
                    color: const Color(0xFFB9F2FF).withOpacity(0.18),
                    shadows: const [
                      Shadow(blurRadius: 16),
                      Shadow(blurRadius: 28),
                    ],
                  ),
                ),
                Text(
                  'Crestarl',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.8,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 1.1
                      ..color = const Color(0xFF7EE8FA).withOpacity(0.6),
                  ),
                ),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    final t = _shineController.value;
                    return LinearGradient(
                      begin: Alignment(-3.0 + t * 2.0, 0),
                      end: Alignment(1.0 + t * 2.0, 0),
                      colors: const [
                        Color(0xFF7EE8FA),
                        Colors.white,
                        Color(0xFF7EE8FA),
                      ],
                      stops: const [0.45, 0.5, 0.55],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Crestarl',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      body: Stack(
        children: [
          // ===== 背景 =====
          Positioned.fill(
            child: Image.asset('assets/bg_neon.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A0033).withOpacity(0.85),
                    const Color(0xFF4A00E0).withOpacity(0.45),
                    const Color(0xFF00C6FF).withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.15)),
            ),
          ),

          // ===== コンテンツ（枠なし）=====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '音声をアップロード',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 20),

                  AudioPickWidget(
                    onAudioSelected: (file) {
                      setState(() => _selectedAudio = file);
                    },
                  ),

                  if (_selectedAudio == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '※ 音声ファイルを選択してください',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Text(
                        'エフェクト',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  Colors.cyanAccent.withOpacity(0.4),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStyle,
                              dropdownColor:
                                  const Color(0xFF2A004F),
                              style:
                                  const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(
                                  value: 'シンプル',
                                  child: Text('シンプル'),
                                ),
                                DropdownMenuItem(
                                  value: 'キラキラ',
                                  child: Text('キラキラ'),
                                ),
                                DropdownMenuItem(
                                  value: 'ナイト',
                                  child: Text('ナイト'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedStyle = value!);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2EDF),
                      elevation: 12,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _selectedAudio == null
                        ? null
                        : _executeSimulation,
                    child: const Text(
                      '実行',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
