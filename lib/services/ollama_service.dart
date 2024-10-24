import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaApiService {
  OllamaApiService();

  Future<String?> generateText(String content) async {
    final url = Uri.parse('http://127.0.0.1:11434/');

    // 準備要傳遞的資料
    final body = jsonEncode({
      "model": "llama3",
      "messages": [
        {
          "role": "user",
          "content": '''
          This is the question you need to reply: $content.
          Your character is Techy. Your responses will always start with 'Bebo!' and will only address simple questions.
          Keep your responses short, with a maximum of 10 words.
          '''
        } // 確保這裡的內容是你想要的格式
      ],
      "stream": false,
    });
    try {
      final response = await http.post(
        url,
        body: body,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API呼叫成功: $data');
        print("回應: ${data['message']['content']}");
        return data['message']['content'];
      } else {
        print("Failed to get response from API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("這是Error: $e");
      return null;
    }
  }
}
