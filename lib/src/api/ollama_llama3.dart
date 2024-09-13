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
        {"role": "user", "content": '$content,reply short'} // 都設為簡短回答
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
