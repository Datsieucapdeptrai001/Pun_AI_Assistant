import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';

class AutoListenScreen extends StatefulWidget {
  const AutoListenScreen({super.key});

  @override
  State<AutoListenScreen> createState() => _AutoListenScreenState();
}

class _AutoListenScreenState extends State<AutoListenScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Nhấn vào nút Micro bên dưới và nói...';
  bool _isLoading = false;
  
  // Loa để phát giọng FPT
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestMicrophonePermission(); // Vừa vào là xin phép ngay
  }

  // Hàm xin quyền Micro
  Future<void> _requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  // Hàm xử lý Thu âm
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Trạng thái Mic: $status');
          // Khi người dùng ngừng nói, hệ thống báo 'done' hoặc 'notListening'
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
            // Đợi 1 nhịp, nếu có chữ thì tự động gửi API luôn, khỏi bắt bấm nút
            if (_text.isNotEmpty && _text != 'Nhấn vào nút Micro bên dưới và nói...') {
              _sendMessageToPun();
            }
          }
        },
        onError: (errorNotification) => print('Lỗi Mic: $errorNotification'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() {
            _text = result.recognizedWords;
          }),
          localeId: 'vi_VN', // TỐI QUAN TRỌNG: Ép bộ lọc nghe tiếng Việt
        );
      }
    } else {
      // Bấm thủ công để tắt
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // Hàm bắn API và phát nhạc (Giống màn Admin)
  Future<void> _sendMessageToPun() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Set mặc định userType là 'guest' để tối ưu phản hồi cho cô Tuyền
      final response = await ApiService.chatWithPun(_text, userType: 'guest');

      setState(() {
        if (response['status'] == 'success') {
          _text = response['reply_text'];
          if (response['audio_url'] != null) {
            // Vẫn giữ hoãn binh 2 giây cho FPT kịp nặn file
            Future.delayed(const Duration(seconds: 2), () {
              _audioPlayer.play(UrlSource(response['audio_url']));
            });
          }
        } else {
          _text = 'Lỗi rùi: ${response['reply_text']}';
        }
      });
    } catch (e) {
      setState(() => _text = 'Trời ơi mạng lác quá Pột ơi!');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _speech.cancel(); // Dọn rác micro
    _audioPlayer.dispose(); // Dọn loa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pủn AI - Chế Độ Rảnh Tay')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        backgroundColor: _isListening ? Colors.red : Colors.blueAccent,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 35),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Text(
                  _text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}