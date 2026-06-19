import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';

// 1. CHỐT CHẶN SINGLETON: Đưa Micro ra ngoài cùng, biến thành tài sản chung của toàn App
final stt.SpeechToText globalSpeech = stt.SpeechToText();

class AutoListenScreen extends StatefulWidget {
  final String userType;
  const AutoListenScreen({super.key, required this.userType});

  @override
  State<AutoListenScreen> createState() => _AutoListenScreenState();
}

class _AutoListenScreenState extends State<AutoListenScreen> {
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
    
    // Mỗi lần mở màn hình, chỉ nạp lại cái Lỗ tai (onStatus) chứ không tạo ống mới
    await globalSpeech.initialize(
      onStatus: (status) {
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
    // Nếu Mic đang bị kẹt ở phiên trước, ép nó tắt đi trước khi nghe mới
    if (globalSpeech.isListening) {
      await globalSpeech.stop();
    }

    if (!_isListening) {
      setState(() {
        _isListening = true;
        _hasSentRequest = false; 
        _text = 'Đang nghe...';
      });
      
      globalSpeech.listen(
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
      globalSpeech.stop();
    }
  }

  Future<void> _sendMessageToPun() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    String textToSend = _text; 
    
    try {
      final response = await ApiService.chatWithPun(textToSend, userType: widget.userType);

      if (!mounted) return; 
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
    // 2. CHỐT CHẶN LIFECYCLE: Chỉ khóa van (stop), TUYỆT ĐỐI không đập ống (cancel)
    if (globalSpeech.isListening) {
      globalSpeech.stop();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pủn AI - Chế Độ Rảnh Tay')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        // Khóa nút Mic lại nếu mạng đang load, chống bấm spam
        onPressed: _isLoading ? null : _listen,
        backgroundColor: _isLoading ? Colors.grey : (_isListening ? Colors.red : Colors.blueAccent),
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