import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaApiService {

  OllamaApiService();

  Future<String?> generateText(String content) async {
    final url = Uri.parse('http://192.168.56.1:11434/api/chat');
    // 準備要傳遞的資料
    final body = jsonEncode({
      "model": "llama3.1",
        "messages": [
        {
          "role": "user",
          "content": '''
          This is the question you need to reply: $content.
          Your character is Techy. Your responses will always start with 'Bebo!' and will only address simple questions.
          請用繁體中文簡短回答，並讓字數限縮在20字以內
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

  Future<String?> recordEvent(String content) async {
    final url = Uri.parse('http://192.168.56.1:11434/api/chat');
    // 準備要傳遞的資料
    final body = jsonEncode({
      "model": "llama3.1",
      "messages": [
        {
          "role": "user",
          "content": '''
          提取以下是見的關鍵字，包括時間、地點、事件名稱，此三者如有缺則預設為未定，以下為須判斷的字串:$content.
          '''
        }
      ],
      "stream": false,
    });

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {"Content-Type": "application/json"},
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
