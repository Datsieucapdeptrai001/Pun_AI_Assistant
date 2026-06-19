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
  // Bỏ từ khóa 'late', khởi tạo ngay lập tức để giữ 1 instance duy nhất
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Nhấn vào nút Micro bên dưới và nói...';
  bool _isLoading = false;
  bool _hasSentRequest = false; 
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await Permission.microphone.request();
    
    await _speech.initialize(
      onStatus: (status) {
        // KIỂM TRA MOUNTED TRƯỚC KHI SETSTATE: Ngăn lỗi tràn bộ nhớ khi đã thoát màn hình
        if (!mounted) return; 

        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
          
          if (!_hasSentRequest && 
              _text.isNotEmpty && 
              _text != 'Nhấn vào nút Micro bên dưới và nói...' && 
              _text != 'Đang nghe...' && 
              !_isLoading) {
            
            _hasSentRequest = true; 
            _sendMessageToPun();
          }
        }
      },
      onError: (errorNotification) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _text = 'Lỗi Mic, bấm nói lại nha!';
          });
        }
      },
    );
  }

  void _listen() async {
    // Ép tắt mọi tiến trình cũ trước khi mở nghe mới
    if (_speech.isListening) {
      await _speech.stop();
    }

    if (!_isListening) {
      setState(() {
        _isListening = true;
        _hasSentRequest = false; 
        _text = 'Đang nghe...';
      });
      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _text = result.recognizedWords;
            });
          }
        },
        localeId: 'vi_VN',
      );
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _sendMessageToPun() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    String textToSend = _text; 
    
    try {
      final response = await ApiService.chatWithPun(textToSend, userType: widget.userType);

      if (!mounted) return; // Chốt chặn: Nếu mami lỡ bấm thoát ra lúc AI đang suy nghĩ
      setState(() {
        if (response['status'] == 'success') {
          _text = response['reply_text'];
          if (response['audio_url'] != null) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _audioPlayer.play(UrlSource(response['audio_url']));
            });
          }
        } else {
          _text = 'Lỗi rùi: ${response['reply_text']}';
        }
      });
    } catch (e) {
      if (mounted) setState(() => _text = 'Trời ơi mạng lác quá!');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    // ÉP GIẢI PHÓNG PHẦN CỨNG TRIỆT ĐỂ KHI THOÁT MÀN HÌNH
    if (_speech.isListening) {
      _speech.stop();
    }
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