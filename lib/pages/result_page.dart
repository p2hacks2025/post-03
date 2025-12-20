import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

const Map<String, String> effectNameJa = {
  'simple': 'シンプル',
  'kirakira': 'キラキラ',
  'night': 'ナイト',
};


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

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin {
  final AudioPlayer _mainPlayer = AudioPlayer();
  final AudioPlayer _cheerPlayer = AudioPlayer();
  Timer? _fadeTimer;

  late final AnimationController _shineController;

  File? _current;
  bool _isPlaying = false;

  Future<void> _playCheerWithFadeIn() async {
    double volume = 0.0;

    await _cheerPlayer.stop();
    await _cheerPlayer.setReleaseMode(ReleaseMode.loop);
    await _cheerPlayer.setVolume(volume);
    await _cheerPlayer.play(AssetSource('sounds/cheer.mp3'));

    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      volume += 0.03;
      if (volume >= 0.12) {
        volume = 0.12;
        timer.cancel();
      }
      _cheerPlayer.setVolume(volume);
    });
  }

  @override
void initState() {
  super.initState();

  _shineController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();
}

  Future<void> _play(File file) async {
    if (_isPlaying) {
      await _mainPlayer.stop();
    }

    await _mainPlayer.play(DeviceFileSource(file.path));

    setState(() {
      _current = file;
      _isPlaying = true;
    });

    _mainPlayer.onPlayerComplete.listen((_) {
      setState(() => _isPlaying = false);
    });
  }

  Future<void> _playWithCheer(File file) async {
    await _mainPlayer.stop();
    await _cheerPlayer.stop();

    await _playCheerWithFadeIn();
    await _mainPlayer.play(DeviceFileSource(file.path));

    setState(() {
      _current = file;
      _isPlaying = true;
    });

    _mainPlayer.onPlayerComplete.listen((_) async {
      _fadeTimer?.cancel();
      await _cheerPlayer.stop();
      setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _mainPlayer.dispose();
    _cheerPlayer.dispose();
    _shineController.dispose();
    super.dispose();
  }

  Widget _audioCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required File file,
    required Color accentColor,
    required VoidCallback onPlay,
  }) {
    final bool isCurrent = _current?.path == file.path;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.7), width: 1.5),
        color: Colors.white.withOpacity(0.1),
      ),
      child: ListTile(
        leading: Icon(icon, color: accentColor),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: IconButton(
          icon: Icon(
            isCurrent && _isPlaying ? Icons.stop : Icons.play_arrow,
            color: accentColor,
            size: 30,
          ),
          onPressed: onPlay,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showKiraKira =
        _isPlaying && _current?.path == widget.processedAudio.path;

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
          // 🌈 ベース背景
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8E2DE2),
                  Color(0xFF4A00E0),
                  Color(0xFF00C6FF),
                ],
              ),
            ),
          ),

          // UI
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.25),
                  ),
                  child: Text(
                    '選択エフェクト：${effectNameJa[widget.effectStyle] ?? widget.effectStyle}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),

                _audioCard(
                  title: '元の音声',
                  subtitle: widget.originalAudio.path.split('/').last,
                  icon: Icons.audiotrack,
                  file: widget.originalAudio,
                  accentColor: Colors.cyanAccent,
                  onPlay: () => _play(widget.originalAudio),
                ),

                _audioCard(
                  title: '生成後の音声',
                  subtitle: widget.processedAudio.path.split('/').last,
                  icon: Icons.auto_awesome,
                  file: widget.processedAudio,
                  accentColor: Colors.pinkAccent,
                  onPlay: () => _playWithCheer(widget.processedAudio),
                ),

                const Spacer(),

                const SizedBox(height: 12),

                SizedBox(
                  height: 80,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isPlaying ? 1.0 : 0.0,
                    child: const WaveBarVisualizer(),
                  ),
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2EDF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('保存しました')));
                  },
                  icon: const Icon(Icons.save),
                  label: const Text(
                    '保存',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WaveBarVisualizer extends StatefulWidget {
  const WaveBarVisualizer({super.key});

  @override
  State<WaveBarVisualizer> createState() => _WaveBarVisualizerState();
}

class _WaveBarVisualizerState extends State<WaveBarVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _WaveBarPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _WaveBarPainter extends CustomPainter {
  final double t;
  _WaveBarPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = 36;
    final barWidth = size.width / barCount;
    final baseY = size.height;

    for (int i = 0; i < barCount; i++) {
      final phase = (i / barCount * 2 * pi) + (t * 2 * pi);
      final height = (sin(phase) + 4) * 0.5 * size.height * 0.8 + 6;

      final paint = Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.pinkAccent.withOpacity(0.9),
                Colors.cyanAccent.withOpacity(0.9),
              ],
            ).createShader(
              Rect.fromLTWH(i * barWidth, baseY - height, barWidth, height),
            );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * barWidth + barWidth * 0.2,
            baseY - height,
            barWidth * 0.6,
            height,
          ),
          const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// class _WaveBarPainter extends CustomPainter {
//   final double t;
//   _WaveBarPainter(this.t);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final barCount = 36;
//     final barWidth = size.width / barCount;
//     final baseY = size.height;

//     // 拍（ドンの瞬間が一番強い）
//     final beat = 1 - t;
//     final punch = pow(beat, 2).toDouble();

//     for (int i = 0; i < barCount; i++) {
//       final rand = Random(i);

//       // 各バーの個性
//       final delay = rand.nextDouble() * 0.25; // 反応遅延
//       final strength = 0.6 + rand.nextDouble() * 0.6; // 強さ
//       final noise = rand.nextDouble() * 0.15; // 微揺れ

//       // バーごとの拍反応
//       final local = max(0.0, punch - delay) * strength + noise;

//       final height = size.height * (0.15 + 0.85 * local);

//       final paint = Paint()
//         ..color = Color.lerp(
//           Colors.pinkAccent,
//           Colors.cyanAccent,
//           rand.nextDouble(),
//         )!.withOpacity(0.95);

//       // □ ブロックで描画
//       canvas.drawRect(
//         Rect.fromLTWH(
//           i * barWidth + barWidth * 0.15,
//           baseY - height,
//           barWidth * 0.7,
//           height,
//         ),
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
