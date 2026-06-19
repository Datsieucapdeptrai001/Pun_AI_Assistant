import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';

class AutoListenScreen extends StatefulWidget {
  final String userType; // Đón nhận chức danh từ màn hình trước truyền sang
  const AutoListenScreen({super.key, required this.userType});

  @override
  State<AutoListenScreen> createState() => _AutoListenScreenState();
}

class _AutoListenScreenState extends State<AutoListenScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Nhấn vào nút Micro bên dưới và nói...';
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech(); // KHỞI TẠO ĐÚNG 1 LẦN DUY NHẤT LÚC MỞ TRANG
  }

  void _initSpeech() async {
    await Permission.microphone.request();
    await _speech.initialize(
      onStatus: (status) {
        print('Trạng thái Mic: $status');
        // Khi người dùng im lặng, hệ thống tự báo ngắt
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
          // Chỉ nổ súng gọi API nếu có chữ thật, chống spam
          if (_text.isNotEmpty && 
              _text != 'Nhấn vào nút Micro bên dưới và nói...' && 
              _text != 'Đang nghe...' && 
              !_isLoading) {
            _sendMessageToPun();
          }
        }
      },
      onError: (errorNotification) {
        print('Lỗi Mic: $errorNotification');
        setState(() => _isListening = false);
      },
    );
  }

  void _listen() async {
    if (!_isListening) {
      setState(() {
        _isListening = true;
        _text = 'Đang nghe...'; // UX: Báo hiệu hệ thống đang mở tai
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
        localeId: 'vi_VN',
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _sendMessageToPun() async {
    setState(() => _isLoading = true);
    String textToSend = _text; 
    
    try {
      // Gắn đúng userType của Pột hoặc Guest vào đây!
      final response = await ApiService.chatWithPun(textToSend, userType: widget.userType);

      setState(() {
        if (response['status'] == 'success') {
          _text = response['reply_text'];
          if (response['audio_url'] != null) {
            Future.delayed(const Duration(seconds: 1), () {
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
    _speech.cancel();
    _audioPlayer.dispose();
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
        child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 35, color: Colors.white),
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
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
      ),
    );
  }
}