import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';

class AdminChatScreen extends StatefulWidget {
  final String userType; 

  const AdminChatScreen({super.key, required this.userType});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  
  // Chỉ dùng duy nhất AudioPlayer để phát nhạc FPT
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ĐÃ XÓA: _initTTS(); Không cần khởi tạo máy đọc robot nữa
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioPlayer.dispose();
    // ĐÃ XÓA: flutterTts.stop();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // 1. Cập nhật UI hiển thị tin nhắn và bật vòng xoay
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _textController.clear();

    try {
      // 2. Bắn API gọi não bộ Pủn
      final response = await ApiService.chatWithPun(text, userType: widget.userType);

      // 3. Xử lý câu trả lời thành công
      setState(() {
        if (response['status'] == 'success') {
          final replyText = response['reply_text'];
          _messages.add({'sender': 'pun', 'text': replyText});
          
          // PHÁT GIỌNG FPT Ở ĐÂY: Có link audio thì vã thẳng vào AudioPlayer
          if (response['audio_url'] != null) {
            _audioPlayer.play(UrlSource(response['audio_url']));
          }

          // ĐÃ XÓA: flutterTts.speak(replyText); -> Trả lại sự bình yên cho App!

        } else {
          _messages.add({'sender': 'pun', 'text': 'Lỗi rùi: ${response['reply_text']}'});
        }
      });
    } catch (error) {
      // BẮT LỖI: Server sập, đứt mạng...
      setState(() {
        _messages.add({'sender': 'pun', 'text': 'Máy chủ đang bảo trì hoặc mạng lag. Ông ráng đợi xíu rùi nhắn lại nha!'});
      });
    } finally {
      // BẢO HIỂM: Luôn tắt vòng xoay
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trò chuyện cùng Pủn AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_none),
            onPressed: () => Navigator.pushNamed(context, '/auto-listen'),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text'] ?? '', style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn chọc Pủn...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}