import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OllamaApiService {

  OllamaApiService();

  // 儲存事件資料到 Firestore
  Future<void> saveEventToFirestore(String? date, String? startTime, String? endTime, String? name, String? location) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    Map<String, dynamic> eventData = {
      'date': date ?? "null",
      'start_time': startTime ?? "null",
      'end_time': endTime ?? "null",
      'name': name ?? "null",
      'location': location ?? "null"
    };

    try {
      await firestore.collection('List').add(eventData);  // 儲存到 List collection
      print("事件已成功儲存到 Firebase Firestore");
    } catch (e) {
      print("儲存事件時發生錯誤: $e");
    }
  }

  Future<String?> generateText(String content) async {

    final url = Uri.parse('http://192.168.56.1:11434/api/chat');
    // 準備要傳遞的資料
    var date = DateTime.now();
    var day = DateFormat('EEEE').format(date);
    print(DateTime.now());
    print(DateFormat('EEEE').format(date));

    final body = jsonEncode({
      "model": "llama3.1:techy",
      // "model": "taide",
        "messages": [
        {
          "role": "user",
          "content": '''今天的日期是$date，$day，$content''',
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

        final content = data['message']['content'];

        // 判斷資料是否為 type=1 或 type=2
        if (content.contains('type=1')) {
          // 使用彈性的方式解析每個欄位，不依賴固定格式
          String? date;
          String? startTime;
          String? endTime;
          String? name;
          String? location;

          // 使用簡單的字串查找來提取信息
          final dateMatch = RegExp(r'date=([0-9]{4}/[0-9]{2}/[0-9]{2})').firstMatch(content);
          if (dateMatch != null) {
            date = dateMatch.group(1);
          }

         // 更彈性的時間格式匹配，允許1或2位數的時間
          final startTimeMatch = RegExp(r'start_time=([0-9]{1,2}:[0-9]{1,2}(?::[0-9]{1,2})?)').firstMatch(content);
          if (startTimeMatch != null) {
            startTime = startTimeMatch.group(1);
          }

          final endTimeMatch = RegExp(r'end_time=([0-9]{1,2}:[0-9]{1,2}(?::[0-9]{1,2})?)').firstMatch(content);
          if (endTimeMatch != null) {
            endTime = endTimeMatch.group(1);
          }


          final nameMatch = RegExp(r'name=([^,]+)').firstMatch(content);
          if (nameMatch != null) {
            name = nameMatch.group(1);
          }

          final locationMatch = RegExp(r'location=([^,\.]+)').firstMatch(content);
          if (locationMatch != null) {
            location = locationMatch.group(1);
          }

          // 打印解析後的資料，允許某些欄位可能為空
          print('日期 = ${date ?? "null"}');
          print('起始時間 = ${startTime ?? "null"}');
          print('結束時間 = ${endTime ?? "null"}');
          print('事件名稱 = ${name ?? "null"}');
          print('地點 = ${location ?? "null"}');
          await saveEventToFirestore(date, startTime, endTime, name, location);

          // 最後回傳聊天回應，去除可能的引號
          // 嘗試匹配有 chatResponse 的情況
          final chatResponseMatch = RegExp(r'chatResponse="?(.+?)"?$').firstMatch(content);
          if (chatResponseMatch != null) {
            // 提取去除引號後的聊天回應
            String chatResponse = chatResponseMatch.group(1)!;
            return chatResponse;
          } else {
            // 沒有 chatResponse，直接返回剩下的字串
            // 找出最後的「.」以分隔結束符和聊天回應
            final separatorIndex = content.lastIndexOf('.');
            if (separatorIndex != -1 && separatorIndex + 1 < content.length) {
              String possibleResponse = content.substring(separatorIndex + 1).trim();
              return possibleResponse;
            }
            // 如果找不到「.」，返回整個內容作為回應
            return content.trim();
          }

        } 
        else if (content.contains('type=2')) {
          // 如果是 type=2，直接提取聊天回應，去除可能的引號
          // 嘗試匹配有 chatResponse 的情況
          final chatResponseMatch = RegExp(r'chatResponse="?(.+?)"?$').firstMatch(content);
          if (chatResponseMatch != null) {
            // 提取去除引號後的聊天回應
            String chatResponse = chatResponseMatch.group(1)!;
            return chatResponse;
          } else {
            // 沒有 chatResponse，直接返回剩下的字串
            // 找出最後的「.」以分隔結束符和聊天回應
            final separatorIndex = content.lastIndexOf('.');
            if (separatorIndex != -1 && separatorIndex + 1 < content.length) {
              String possibleResponse = content.substring(separatorIndex + 1).trim();
              return possibleResponse;
            }
            // 如果找不到「.」，返回整個內容作為回應
            return content.trim();
          }
        }
        else {
          print("Failed to get response from API: ${response.statusCode}");
          return null;
        }
      } 
    }catch (e) {
      print('發生錯誤: $e');
      return null;
    }
  }

  Future<String?> recordEvent(String content) async {
    final url = Uri.parse('http://192.168.56.1:11434/api/chat');
    var date = DateTime.now();
    var day = DateFormat('EEEE').format(date);
    print(DateTime.now());
    print(DateFormat('EEEE').format(date));
    // 準備要傳遞的資料;
    final body = jsonEncode({
      "model": "llama3.1:techy",
      // "model": "taide",
      "messages": [
        {
          "role": "user",
          "content": '''今天的日期是$date，$day，$content''',
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
