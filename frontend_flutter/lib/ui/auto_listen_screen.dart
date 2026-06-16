import 'package:flutter/material.dart';

class AutoListenScreen extends StatelessWidget {
  const AutoListenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chế Độ Rảnh Tay'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, size: 100, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text('Tính năng nghe tự động đang được xây dựng...', 
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}