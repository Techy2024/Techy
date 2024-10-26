import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  User? currentUser;
  CollectionReference? listCollection;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser!.uid;
      listCollection = FirebaseFirestore.instance
          .collection('UserID')
          .doc(uid)
          .collection('List');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('測試頁面'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: currentUser != null
              ? () => updateTags(context)
              : null, // 若未登入則停用按鈕
          child: Text('分類並新增 Tag'),
        ),
      ),
    );
  }

  // 更新每筆資料的 tag 欄位
  Future<void> updateTags(BuildContext context) async {
    try {
      if (listCollection == null) {
        throw Exception('尚未取得使用者資料');
      }

      // 取得 List collection 中的所有資料
      QuerySnapshot snapshot = await listCollection!.get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;
        var startTime = data?['start_time'];
        var tag = data?['tag'];

        // 如果 tag 已經存在則略過更新
        if (tag != null) {
          print('跳過 ${doc.id}, tag 已存在');
          continue;
        }

        // 判斷類別並設定 tag 的值
        int newTag = (startTime != null && startTime != 'null') ? 1 : 2;

        // 更新該 document 的 tag 欄位
        await doc.reference.update({'tag': newTag});
        print('已更新 ${doc.id} 的 tag 為 $newTag');
      }

      print('所有資料更新完成');
      _showDialog(context, '成功', '所有資料已更新');
    } catch (e) {
      print('更新資料時發生錯誤: $e');
      _showDialog(context, '錯誤', '更新資料時發生錯誤: $e');
    }
  }

  // 顯示結果對話框
  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('確定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
