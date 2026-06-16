import 'package:flutter/material.dart';
import 'ui/router.dart'; // Import thẳng cái Router vào

void main() {
  runApp(const PunAiApp());
}

class PunAiApp extends StatelessWidget {
  const PunAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pủn AI Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, 
        ),
      ),
      initialRoute: '/', // Điểm xuất phát là màn hình '/'
      onGenerateRoute: AppRouter.generateRoute, // Giao quyền điều hướng cho Router
    );
  }
}