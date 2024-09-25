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
          你的角色是「Techy」，回答時需以「Techy!」開頭，只需回答簡單問題。
          以下是你需要回答的問題：$content。
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
    // 準備要傳遞的資料;
    final body = jsonEncode({
      "model": "llama3.1",
      // "model": "taide",
      "messages": [
        {
          "role": "user",
          "content": '''
          
          規則：
          - 請記住，現在的日期與時間為：${DateTime.now()}，格式為年:月:日 時:分:秒。
          - 若出現「明天」，代表為今天日期加一天。
          - 若出現「後天」，代表為今天日期加兩天。
          - 時間皆紀錄為"年:月:日 時:分:秒"。
          - 早上：08:00~12:00
          - 中午：12:00~13:00
          - 下午：13:00~18:00
          - 晚上：18:00~00:00
          - 事件名稱可以是由此三種元素組合而成 : 主詞 、動詞 、地點
          
          請根據這些規則判斷時間，提取以下字串中的關鍵字，包括時間、地點、事件名稱，若有缺則預設為未定。
          回應的格式為 :  事件名稱 : " "，時間 : "年:月:日 時:分:秒" ， 地點 : " "，
          要分析的字串內容如下：$content。
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
            print('現在時間: ${DateTime.now()}');
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
