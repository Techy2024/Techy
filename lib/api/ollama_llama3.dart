import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OllamaApiService {
  OllamaApiService();

  // 儲存事件資料到 Firestore，並設定 documentID 為有序列的數字
  Future<void> saveEventToFirestore(String? date, String? startTime,
      String? endTime, String? name, String? location, int tag) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    String uid = currentUser.uid;

    // 獲取目前的最大 documentID
    final querySnapshot = await firestore
        .collection('UserID')
        .doc(uid)
        .collection('Chat')
        .orderBy(FieldPath.documentId)
        .get();
    int newDocId = 1; // 預設值為 1

    if (querySnapshot.docs.isNotEmpty) {
      final lastDocId = int.parse(querySnapshot.docs.last.id);
      newDocId = lastDocId + 1; // 新 documentID 為最後一個 documentID 加 1
    }

    Map<String, dynamic> eventData = {
      'date': date ?? "null",
      'start_time': startTime ?? "null",
      'end_time': endTime ?? "null",
      'name': name ?? "null",
      'location': location ?? "null",
      'tag': tag,
    };

    try {
      await firestore
          .collection('UserID')
          .doc(uid)
          .collection('Chat')
          .doc(newDocId.toString())
          .set(eventData); // 儲存到 List collection，使用新的 documentID
      print("事件已成功儲存到 Firebase Firestore，documentID: $newDocId");
    } catch (e) {
      print("儲存事件時發生錯誤: $e");
    }
  }

  // 儲存聊天記錄到 Firestore，並設定 documentID 為有序列的數字
  Future<void> saveChatToFirestore(String ask, String reply) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    String uid = currentUser.uid;

    // 獲取目前的最大 documentID
    final querySnapshot = await firestore
        .collection('UserID')
        .doc(uid)
        .collection('Chat')
        .orderBy(FieldPath.documentId)
        .get();
    int newDocId = 1; // 預設值為 1

    if (querySnapshot.docs.isNotEmpty) {
      final lastDocId = int.parse(querySnapshot.docs.last.id);
      newDocId = lastDocId + 1; // 新 documentID 為最後一個 documentID 加 1
    }

    Map<String, dynamic> chatData = {
      'ask': ask,
      'reply': reply,
      'timestamp': FieldValue.serverTimestamp(), // 儲存時間戳
    };

    try {
      await firestore
          .collection('UserID')
          .doc(uid)
          .collection('Chat')
          .doc(newDocId.toString())
          .set(chatData); // 儲存到 Chat collection，使用新的 documentID
      print("聊天記錄已成功儲存到 Firebase Firestore，documentID: $newDocId");
    } catch (e) {
      print("儲存聊天記錄時發生錯誤: $e");
    }
  }

  Future<String?> generateText(String text) async {
    //final url = Uri.parse('http://192.168.56.1:11434/api/chat');
    final url = Uri.parse('http://localhost:11434/api/chat');
    // 準備要傳遞的資料
    var date = DateTime.now();
    var day = DateFormat('EEEE').format(date);
    print(DateTime.now());
    print(DateFormat('EEEE').format(date));

    final body = jsonEncode({
      //"model": "llama3.1:techy",
      "model": "llama3:latest",
      // "model": "taide",
      "messages": [
        {
          "role": "user",

          //"content": '''今天的日期是$date，$day。使用者傳入的訊息是:$text''',
          "content": "What is 2+2?"
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

        // 判斷資料是否為 type=1
        if (content.contains('type=1')) {
          // 使用彈性的方式解析每個欄位，不依賴固定格式
          String? date;
          String? startTime;
          String? endTime;
          String? name;
          String? location;

          // 使用簡單的字串查找來提取信息
          final dateMatch =
              RegExp(r'date=([0-9]{4}/[0-9]{2}/[0-9]{2})').firstMatch(content);
          if (dateMatch != null) {
            date = dateMatch.group(1);
          }

          // 更彈性的時間格式匹配，允許1或2位數的時間
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

          // 打印解析後的資料，允許某些欄位可能為空
          print('日期 = ${date ?? "null"}');
          print('起始時間 = ${startTime ?? "null"}');
          print('結束時間 = ${endTime ?? "null"}');
          print('事件名稱 = ${name ?? "null"}');
          print('地點 = ${location ?? "null"}');

          // 設置 tag 的值
          int tag = (startTime != null && startTime != 'null') ? 1 : 2;

          // 保存事件到 Firestore，包括 tag
          await saveEventToFirestore(
              date, startTime, endTime, name, location, tag);

          // 嘗試匹配有 chatResponse 的情況
          final chatResponseMatch =
              RegExp(r'chatResponse="?(.+?)"?$').firstMatch(content);
          if (chatResponseMatch != null) {
            // 提取去除引號後的聊天回應
            String chatResponse = chatResponseMatch.group(1)!;

            // 儲存聊天記錄到 Firestore
            await saveChatToFirestore(text, chatResponse);

            return chatResponse;
          } else {
            // 沒有 chatResponse，直接返回剩下的字串
            final separatorIndex = content.lastIndexOf('.');
            if (separatorIndex != -1 && separatorIndex + 1 < content.length) {
              String possibleResponse =
                  content.substring(separatorIndex + 1).trim();

              // 儲存聊天記錄到 Firestore
              await saveChatToFirestore(text, possibleResponse);

              return possibleResponse;
            }
            // 儲存聊天記錄到 Firestore
            await saveChatToFirestore(text, content.trim());

            return content.trim();
          }
        } else {
          // 如果是 type=2，直接提取聊天回應，去除可能的引號
          final chatResponseMatch =
              RegExp(r'chatResponse="?(.+?)"?$').firstMatch(content);
          if (chatResponseMatch != null) {
            String chatResponse = chatResponseMatch.group(1)!;

            // 儲存聊天記錄到 Firestore
            await saveChatToFirestore(text, chatResponse);

            return chatResponse;
          } else {
            final separatorIndex = content.lastIndexOf('.');
            if (separatorIndex != -1 && separatorIndex + 1 < content.length) {
              String possibleResponse =
                  content.substring(separatorIndex + 1).trim();

              // 儲存聊天記錄到 Firestore
              await saveChatToFirestore(text, possibleResponse);

              return possibleResponse;
            }

            // 儲存聊天記錄到 Firestore
            await saveChatToFirestore(text, content.trim());

            return content.trim();
          }
        }
      }
    } catch (e) {
      print('發生錯誤: $e');
      return null;
    }
  }
}
