import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';

class AutoListenScreen extends StatefulWidget {
  final String userType;
  const AutoListenScreen({super.key, required this.userType});

  @override
  State<AutoListenScreen> createState() => _AutoListenScreenState();
}

class _AutoListenScreenState extends State<AutoListenScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Nhấn vào nút Micro bên dưới và nói...';
  bool _isLoading = false;
  
  // CỜ BẢO VỆ TỐI CAO: Chống trùng lặp lệnh do Race Condition
  bool _hasSentRequest = false; 
  
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    await Permission.microphone.request();
    await _speech.initialize(
      onStatus: (status) {
        print('Trạng thái Mic từ hệ thống: $status');
        
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
          
          // CHỐT CHẶN: Chỉ nổ súng nếu CHƯA từng gửi request trong phiên nói này
          if (!_hasSentRequest && 
              _text.isNotEmpty && 
              _text != 'Nhấn vào nút Micro bên dưới và nói...' && 
              _text != 'Đang nghe...' && 
              !_isLoading) {
            
            _hasSentRequest = true; // Khóa chốt ngay lập tức!
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
        _hasSentRequest = false; // Reset lại cờ khi bắt đầu một phiên nói mới
        _text = 'Đang nghe...';
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
      final response = await ApiService.chatWithPun(textToSend, userType: widget.userType);

      setState(() {
        if (response['status'] == 'success') {
          _text = response['reply_text'];
          if (response['audio_url'] != null) {
            // Tăng lên 2 giây cho mami thoải mái đợi FPT nặn nhạc giống màn Chat chữ
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