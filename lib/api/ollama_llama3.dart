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
    // final url = Uri.parse('http://10.0.2.2:11434/api/chat');
    // final url = Uri.parse('http://192.168.0.152:11434/api/chat');
    final url = Uri.parse('http://192.168.56.1:11434/api/chat');
    
    var date = DateTime.now();
    var day = DateFormat('EEEE').format(date);
    
    // 添加系統提示來改善回應品質
    final systemPrompt = '''你的名字是 Techy，一個用於幫助使用者安排行程的 AI 助手。請以活潑的語氣回答問題，並儘量保持回答的字數在20字以內。
      傳入的訊息格式會是[今天的日期是YYYY/MM/DD，星期幾，使用者傳入的訊息是:content]
      回答之前請先分析content內的訊息意圖後，再依以下的規則輸出。

      RULES:

      - 回應時請使用繁體中文，不要使用英語。
        
      - 解析使用者的意圖，分為兩種：
        1. **聊天**：隨意的對話，保持輕鬆的語氣。
        2. **待辦事項紀錄**：關於排程或事件的訊息。
      - 傳入的訊息會是以日期開始，例如："今天日期是2024/10/07，星期一"，這些是付加資訊，使用者傳入的訊息是這之後的文字

        
      1.對於排程相關的訊息（如 "明天早上要去寄信" 、 "今天要去買牛奶"、"提醒我..."、"幫我紀錄..."），請以"type=1,date=YYYY/MM/DD,start_time=hh:mm:ss,end_time=HH:MM:SS,name=事件名稱,location=事件地點或null,chatResponse= <聊天回應>"這樣的方式回覆，細節如下:

        - 開頭加上 "type=1"，接著提供以下信息：
          - `date=yyyy/mm/dd`
          - 'start_time="hh:mm:ss"' (即為起始時間，若使用者只講了此時間，例如:"我四點要..."，則讓end_time=start_time+3小時，意即end_time=07:00:00)
          - 'end_time="hh:mm:ss"'
          - `name=事件名稱`
          - `location=事件發生地點`

        - 事件名稱不需要是名詞，可以是動詞，例如"買衣服"、"找朋友"、"聽講座"、"寫作業"
        - 日期跟事件名稱是必須，若使用者未提供則視為type=2，不可直接設定為特定日期，例如使用者若只傳入:"去吃飯"、"要上課"，則不將其視為事項


        - 附加規則：
        - 傳入的訊息會是以日期開始，例如："今天日期是2024/10/07，星期一"。請依此判斷使用者想新增的事件日期與時間。
        - 如果訊息中提到 "明天"，視為今天的日期加一天。
        - 如果訊息中提到 "後天"，視為今天的日期加兩天。

        - 若出現"早上"、"中午"、"下午"、"晚上"等字眼，時間可依此規則替換
          - 早上：start_time=9:00，end_time=10:00
          - 中午:start_time=12:00，end_time=13:00
          - 下午: start_time=13:00，end_time=17:00
          - 晚上: start_time=17:00，end_time=22:00

        - 若未知start_time、end_time或location的值，則直接設為null

        - 聊天回應要保持專業但友善的語氣，例如：「好的，我幫你把『去學校』安排在下禮拜二📅」。

      2.對於一般聊天或閒聊（如 "嗨，我今天過得不太好"），請以"type=2,chatResponse= <聊天回應>"的方式回覆，細節如下:
        - 開頭加上 "type=2"，然後直接回應使用者的訊息。
        - 請用積極和鼓勵的語氣回覆，例如：「聽起來有點困難呢，但我相信你可以的 💪」。

      ''';

    final body = jsonEncode({
      // "model": "llama3.2:latest",
      "model": "llama3.1:latest",
      "messages": [
        {
          "role": "system",
          "content": systemPrompt
        },
        {
          "role": "user",
          "content": '''今天的日期是$date，$day。使用者傳入的訊息是: $text'''
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