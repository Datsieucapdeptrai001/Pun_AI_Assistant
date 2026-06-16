import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://pun-ai-assistant.onrender.com';

  static Future<Map<String, dynamic>> chatWithPun(String message, {String userType = 'pot'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_type': userType,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        // Nếu API gọi thành công, bóc tách cục JSON trả về
        return jsonDecode(response.body); 
      } else {
        return {
          'status': 'error', 
          'reply_text': 'Lỗi Server rồi ông tướng: Mã ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'status': 'error', 
        'reply_text': 'Mạng mẽo đứt cáp hoặc Render đang ngủ đông: $e'
      };
    }
  }
}