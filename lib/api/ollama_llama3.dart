import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OllamaApiService {
  OllamaApiService();

  Future<void> saveEventToFirestore(String? date, String? startTime,
      String? endTime, String? name, String? location, int tag) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    String uid = currentUser.uid;

    Map<String, dynamic> eventData = {
      'date': date ?? "null",
      'start_time': startTime ?? "null",
      'end_time': endTime ?? "null",
      'name': name ?? "null",
      'location': location ?? "null",
      'tag': tag,
    };
    try {
      DocumentReference docRef = firestore
          .collection('UserID')
          .doc(uid)
          .collection('List')
          .doc();
      await docRef.set(eventData);
      print("事件已成功儲存到 Firebase Firestore，documentID: ${docRef.id}");
    } catch (e) {
      print("儲存事件時發生錯誤: $e");
    }
  }
  Future<void> saveChatToFirestore(String ask, String reply) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    String uid = currentUser.uid;

    Map<String, dynamic> chatData = {
      'ask': ask,
      'reply': reply,
      'timestamp': FieldValue.serverTimestamp(),
    };
    
    try {
      DocumentReference docRef = firestore
          .collection('UserID')
          .doc(uid)
          .collection('Chat')
          .doc();
      await docRef.set(chatData);
      print("聊天記錄已成功儲存到 Firebase Firestore，documentID: ${docRef.id}");
    } catch (e) {
      print("儲存聊天記錄時發生錯誤: $e");
    }
  }

  Future<String?> generateText(String text) async {
    final url = Uri.parse('http://10.0.2.2:11434/api/chat');
    // final url = Uri.parse('http://192.168.0.152:11434/api/chat');
    var date = DateTime.now();
    var day = DateFormat('EEEE').format(date);
    
    // 添加系統提示來改善回應品質
    final systemPrompt = '''您是一個助理，主要工作是:
1. 辨識用戶的輸入是否包含日程相關資訊
2. 如果包含日程，請以下列格式輸出:
   type=1,date=YYYY/MM/DD,start_time=HH:mm,end_time=HH:mm,name=事件名稱,location=地點,chatResponse=您的回應
3. 如果不包含日程，請以下列格式輸出:
   type=2,chatResponse=您的回應
4. 請用中文回應
5. 回應要簡潔、具體且有幫助''';

    final body = jsonEncode({
      "model": "llama3.2:latest",
      "messages": [
        {
          "role": "system",
          "content": systemPrompt
        },
        {
          "role": "user",
          "content": '''今天的日期是$date，$day。用戶訊息: $text'''
        }
      ],
      "stream": false
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

        // 其餘的解析邏輯保持不變...
        if (content.contains('type=1')) {
          // 原有的type=1解析邏輯...
          String? date;
          String? startTime;
          String? endTime;
          String? name;
          String? location;

          final dateMatch =
              RegExp(r'date=([0-9]{4}/[0-9]{2}/[0-9]{2})').firstMatch(content);
          if (dateMatch != null) {
            date = dateMatch.group(1);
          }

          final startTimeMatch =
              RegExp(r'start_time=([0-9]{1,2}:[0-9]{1,2}(?::[0-9]{1,2})?)')
                  .firstMatch(content);
          if (startTimeMatch != null) {
            startTime = startTimeMatch.group(1);
          }

          final endTimeMatch =
              RegExp(r'end_time=([0-9]{1,2}:[0-9]{1,2}(?::[0-9]{1,2})?)')
                  .firstMatch(content);
          if (endTimeMatch != null) {
            endTime = endTimeMatch.group(1);
          }

          final nameMatch = RegExp(r'name=([^,]+)').firstMatch(content);
          if (nameMatch != null) {
            name = nameMatch.group(1);
          }

          final locationMatch =
              RegExp(r'location=([^,\.]+)').firstMatch(content);
          if (locationMatch != null) {
            location = locationMatch.group(1);
          }

          print('日期 = ${date ?? "null"}');
          print('起始時間 = ${startTime ?? "null"}');
          print('結束時間 = ${endTime ?? "null"}');
          print('事件名稱 = ${name ?? "null"}');
          print('地點 = ${location ?? "null"}');

          int tag = (startTime != null && startTime != 'null') ? 1 : 2;
          await saveEventToFirestore(date, startTime, endTime, name, location, tag);

          final chatResponseMatch =
              RegExp(r'chatResponse="?(.+?)"?$').firstMatch(content);
          if (chatResponseMatch != null) {
            String chatResponse = chatResponseMatch.group(1)!;
            await saveChatToFirestore(text, chatResponse);
            return chatResponse;
          }
        } else {
          final chatResponseMatch =
              RegExp(r'chatResponse="?(.+?)"?$').firstMatch(content);
          if (chatResponseMatch != null) {
            String chatResponse = chatResponseMatch.group(1)!;
            await saveChatToFirestore(text, chatResponse);
            return chatResponse;
          }
        }
        
        // 如果上述都沒有匹配到，返回原始內容
        await saveChatToFirestore(text, content.trim());
        return content.trim();
      }
    } catch (e) {
      print('發生錯誤: $e');
      return null;
    }
    return null;
  }
}