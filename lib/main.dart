import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/character_select_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DianyunApp());
}

class DianyunApp extends StatelessWidget {
  const DianyunApp({super.key});

  // 默认 API Key（展示版使用，实际生产建议走云函数转发）
  static const String defaultApiKey = 'sk-9f4bf5c1920b46c49e528a768f9240fa';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '典韵智创',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A6FA5)),
        useMaterial3: true,
        fontFamily: 'Default',
      ),
      home: const CharacterSelectPage(apiKey: defaultApiKey),
    );
  }
}
