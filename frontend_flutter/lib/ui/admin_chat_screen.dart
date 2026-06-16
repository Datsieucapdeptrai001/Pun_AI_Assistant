import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/api_service.dart';

class AdminChatScreen extends StatefulWidget {
  final String userType; // Thêm biến này để nhận diện nhân vật

  const AdminChatScreen({super.key, required this.userType});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // 1. Cập nhật UI hiển thị tin nhắn của Pụt/Pột và bật vòng xoay
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
          _messages.add({'sender': 'pun', 'text': response['reply_text']});
          // Có link audio thì phát nhạc luôn
          if (response['audio_url'] != null) {
            _audioPlayer.play(UrlSource(response['audio_url']));
          }
        } else {
          _messages.add({'sender': 'pun', 'text': 'Lỗi rùi: ${response['reply_text']}'});
        }
      });
    } catch (error) {
      // BẮT LỖI: Server sập, đứt mạng, timeout...
      setState(() {
        _messages.add({'sender': 'pun', 'text': 'Máy chủ đang bảo trì hoặc mạng lag. Ông ráng đợi xíu rùi nhắn lại nha!'});
      });
    } finally {
      // BẢO HIỂM TỐI THƯỢNG: Luôn tắt vòng xoay dù thành công hay thất bại
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
          // Khu vực hiển thị tin nhắn
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
          // Hiển thị vòng xoay đang tải khi đợi API
          if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
          // Khung nhập liệu
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