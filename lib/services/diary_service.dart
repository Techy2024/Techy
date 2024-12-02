import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/llama_dairy.dart';

class DiaryService extends ChangeNotifier {
  final LlamaService _llamaService = LlamaService();
  List<String> diaryEntries = [];
  Timer? _dailyDiaryTimer;

  DiaryService() {
    _loadInitialDiaryEntries();
    _startDiaryGeneration();
  }

  void _loadInitialDiaryEntries() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("未登入，無法載入日記");
      return;
    }

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('UserID')
          .doc(currentUser.uid)
          .collection('Diaries')
          .orderBy('date', descending: true)
          .get();

      diaryEntries = querySnapshot.docs.map((doc) {
        String date =  doc.id;
        String content = doc['content'];
        return "$date: \n\n$content";
      }).toList();

      notifyListeners();
    } catch (e) {
      print("載入日記時發生錯誤: $e");
    }
  }

  void _startDiaryGeneration() {
    print('啟動日記生成計時器');
    
    _dailyDiaryTimer = Timer.periodic(Duration(minutes: 2), (Timer timer) async {
      await _generateDailyDiary();
    });
  }

  Future<List<String>> _fetchChatLogs() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("未登入，無法獲取對話記錄。");
      return [];
    }

    String uid = currentUser.uid;

    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      QuerySnapshot querySnapshot = await firestore
          .collection('UserID')
          .doc(uid)
          .collection('Chat')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc['ask'] as String)
          .toList();
    } catch (e) {
      print("獲取聊天記錄時發生錯誤: $e");
      return [];
    }
  }

  Future<void> _generateDailyDiary() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("未登入，無法獲取對話記錄。");
      return;
    }

    String uid = currentUser.uid;
    final chatLogs = await _fetchChatLogs();

    try {
      final diary = await _llamaService.generateDiary(uid, chatLogs);
      await _saveDiaryToFirebase(uid, diary);

      diaryEntries.insert(0, "${DateTime.now().toIso8601String()}: \n\n$diary");
      notifyListeners();

      print("日記已成功生成並儲存。");
    } catch (e) {
      print("日記生成失敗: $e");
    }
  }

  Future<void> _saveDiaryToFirebase(String uid, String diary) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String dateId = DateTime.now().toIso8601String().split('T')[0];

    Map<String, dynamic> diaryData = {
      'content': diary,
    };

    try {
      DocumentReference docRef = firestore
          .collection('UserID')
          .doc(uid)
          .collection('Diaries')
          .doc(dateId);

      await docRef.set(diaryData);
      print("日記已成功儲存到 Firebase Firestore，ID: $dateId");
    } catch (e) {
      print("儲存日記時發生錯誤: $e");
    }
  }

  @override
  void dispose() {
    _dailyDiaryTimer?.cancel();
    super.dispose();
  }
}