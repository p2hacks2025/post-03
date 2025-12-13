import 'package:flutter/material.dart';
import 'pages/upload_page.dart';

void main() {
  runApp(const IlluminationApp());
}

class IlluminationApp extends StatelessWidget {
  const IlluminationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Illumination Simulation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const UploadPage(),
    );
  }
}
