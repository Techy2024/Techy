import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaApiService {

  OllamaApiService();

  Future<String?> generateText(String content) async {
    final url = Uri.parse('http://192.168.56.1:11434/api/chat');
    // 準備要傳遞的資料
    final body = jsonEncode({
      "model": "llama3.1",
      // "model": "taide",
        "messages": [
        {
          "role": "user",
          "content": '''
          以下是你需要回答的問題：$content。
          你的角色是「Techy」，回答時需以「Techy!」開頭，只需回答簡單問題。
          請用繁體中文簡短回答，字數限縮在20字以內。
          '''
        }
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
      // "model": "taide",
      "messages": [
        {
          "role": "user",
          "content": '''
          請提取以下字串中的關鍵字，包括時間、地點、事件名稱，若有缺則預設為未定。字串內容如下：$content。
          
          規則：
          - 當前時間為：${DateTime.now()}。
          - 若出現「明天」，代表為今天日期加一天。
          - 若出現「後天」，代表為今天日期加兩天。
          - 早上：08:00~12:00
          - 中午：12:00~13:00
          - 下午：13:00~18:00
          - 晚上：18:00~00:00
          
          請根據這些規則判斷時間，並提取時間、地點和事件名稱。
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
