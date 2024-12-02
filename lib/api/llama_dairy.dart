import 'package:http/http.dart' as http;
import 'dart:convert';

class LlamaService {
  Future<String> generateDiary(String userId, List<String> chatLogs) async {
    final url = Uri.parse('http://192.168.56.1:11434/api/chat');
    final prompt =
        "使用者是一位學生，請重點放於使用者講的話，並不強調此段對話，生成30~50字的短篇日記";

    // 將 chatLogs 列表轉換為單一字符串，使用換行符分隔每一條記錄
    final chatContent = chatLogs.join("\n");
    print('這是chat:$chatContent');
    final body = jsonEncode({
      "model": "llama3.2:latest",
      "messages": [
        {
          "role": "system",
          "content": prompt
        },
        {
          "role": "user",
          "content": chatContent // 傳遞合併後的聊天內容
        }
      ],
      "stream": false
    });
        print('這是body:$body');
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json", // 加上 Content-Type 頭
        },
        body: body,
      );
        print('這是日記:$response');
        print('這是日記回應: ${response.body}');

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);
        if (data.containsKey("message") && data["message"].containsKey("content")) {
          return data["message"]["content"] ?? "日記生成失敗";
        } else {
          throw Exception("回應中未包含日記內容");
        }
      } else {
        throw Exception("無法生成日記，HTTP狀態碼: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("日記生成過程中出現錯誤: $e");
    }
  }
}
