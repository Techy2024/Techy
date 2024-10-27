import 'package:bookfx/bookfx.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/api/ollama_llama3.dart';
import 'package:final_project/pages/Diary.dart';
import 'package:final_project/pages/Note.dart';
import 'package:final_project/pages/calendar_page.dart';
import 'package:final_project/pages/test_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:final_project/services/location_service.dart'; // 引入 LocationService
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  // logout
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  String type = 'ENFJ'; // 定義 GIF 類型的變數
  String _gifPath = 'lib/assets/gif/INTJ/shake_head.gif';
  final TextEditingController _controller = TextEditingController();
  String? _apiResponse; // API 的回應
  final OllamaApiService apiService = OllamaApiService();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0.0;

  Future<void> setUserTypeFromFirestore() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('UserID')
            .doc(uid)
            .get();

        if (doc.exists && doc.data() != null) {
          String? characterType = doc['character_type']; // 獲取 character_type 的值
          setState(() {
            type = characterType ?? 'ENFJ'; // 若無值則使用預設值
            _gifPath = 'lib/assets/gif/$type/shake_head.gif'; // 設置 GIF 路徑
          });
        }
      } catch (e) {
        print('Error fetching character_type: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setUserTypeFromFirestore();
    initSpeech();
  }

  Future<void> initSpeech() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('麥克風權限未授權');
      return; // 若無權限則返回
    }

    _speechEnabled = await _speechToText.initialize(
      onError: (error) => print('SpeechToText Error: $error'),
    );

    if (!_speechEnabled) {
      print('SpeechToText 初始化失敗');
    } else {
      print('SpeechToText 初始化成功');
    }
    setState(() {}); // 更新狀態
  }

  void _startListening() async {
    if (_speechEnabled) {
      // 確認初始化成功後才開始聆聽
      print('start...');
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: 'zh_CN', // 中文
      );
      setState(() {
        _gifPath = 'lib/assets/gif/$type/wave_hand.gif';
        _confidenceLevel = 0;
      });
    } else {
      print('SpeechToText 尚未初始化');
    }
  }

  void _stopListening() async {
    print('stop...');
    await _speechToText.stop();

    // 等待 UI 更新完成
    await Future.delayed(Duration(milliseconds: 1000)); // 調整延遲時間以確保值已更新

    // 確保在 API 調用前 _wordsSpoken 是最新的
    final recognizedWords = _wordsSpoken;

    // 异步调用记录事件的方法
    print("Recognized words before API call: $recognizedWords");
    final event = await apiService.generateText(recognizedWords);
    setState(() {
      _gifPath = 'lib/assets/gif/$type/shake_head.gif'; // 使用變數 type
    });
  }

  void _onSpeechResult(result) async {
    // 提取识别的文字
    final recognizedWords = result.recognizedWords;
    final confidenceLevel = result.confidence;

    // 更新 UI 状态
    setState(() {
      _wordsSpoken = recognizedWords;
      _confidenceLevel = confidenceLevel;
    });
  }

  void _sendMessage(BuildContext context) async {
    print("Sending message...");
    final message = _controller.text;
    if (message.isNotEmpty) {
      // 调用 API 并获得结果
      final response = await apiService.generateText(message);
      setState(() {
        _apiResponse = response; // 直接將 API 返回的內容設置為回應
        _gifPath = 'lib/assets/gif/$type/jump.gif'; // 使用變數 type
      });
      _controller.clear(); // 发送后清空输入框

      // 三秒后恢复原始 GIF
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _apiResponse = null;
          _gifPath = 'lib/assets/gif/$type/shake_head.gif'; // 使用變數 type
        });
      });
    }

    final user = FirebaseAuth.instance.currentUser!;
    void signUserOut() {
      FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Home'), // 設置導航欄標題
        trailing: IconButton(
          icon: const Icon(CupertinoIcons.share),
          onPressed: () {
            FirebaseAuth.instance.signOut(); // 登出
          },
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/image/home.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // 顯示 API 回應的框
            if (_apiResponse != null)
              Positioned(
                bottom: 300,
                left: 30,
                right: 180,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 227, 227, 227)
                        .withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _apiResponse!,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),

            // 顯示 GIF 圖片
            Positioned(
              bottom: 100,
              left: 0,
              child: Container(
                width: 400, // 設置 GIF 顯示的寬度
                child: Image.asset(_gifPath), // 加載 GIF
              ),
            ),

            // Note 按钮
            Positioned(
              top: 190,
              right: 30,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => NotePage()), // 跳转到 NotePage
                  );
                },
                child: SizedBox(
                  width: 130,
                  height: 100,
                  child: CupertinoButton(
                    child: Container(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => NotePage()), // 跳转到 NotePage
                      );
                    },
                    padding: EdgeInsets.all(0), // 移除内边距
                  ),
                ),
              ),
            ),

            // Calendar 按钮
            Positioned(
              top: 220,
              left: 50,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) =>
                            CalendarPage()), // 直接跳轉到 CalendarPage
                  );
                },
                child: SizedBox(
                  width: 130, // 设定宽度
                  height: 150, // 设定高度
                  child: CupertinoButton(
                    child: Container(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => CalendarPage()), // 直接跳转页面
                      );
                    },
                    padding: EdgeInsets.all(0), // 移除内边距
                  ),
                ),
              ),
            ),

            // Diary 按钮
            Positioned(
              top: 450,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => DiaryPage()),
                  );
                },
                child: SizedBox(
                  width: 90, // 設定寬度
                  height: 80, // 設定高度
                  child: Container(
                    // 替換掉 CupertinoButton，使用單純的 Container
                    decoration: BoxDecoration(
                      color: Colors.transparent, // 你可以設定顏色或透明
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '當前位置:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    locationService.location,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // 底部输入框和发送按钮
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 水平居中对齐
                  children: [
                    SizedBox(
                      width: 200,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[800]!, // 深灰色邊框
                            width: 1.0, // 邊框寬度
                          ),
                          color: const Color.fromARGB(255, 194, 194, 194)
                              .withOpacity(0.8), // 設置底色
                          borderRadius: BorderRadius.circular(10.0), // 圓角
                        ),
                        child: CupertinoTextField(
                          controller: _controller,
                          placeholder: "Type a message",
                          onSubmitted: (value) => _sendMessage(context),
                        ),
                      ),
                    ),
                    CupertinoButton(
                      child: Icon(CupertinoIcons.paperplane),
                      onPressed: () => _sendMessage(context),
                    ),
                    CupertinoButton(
                      child: Icon(
                        _speechToText.isNotListening
                            ? Icons.mic_off
                            : Icons.mic,
                      ),
                      onPressed: _speechToText.isListening
                          ? _stopListening
                          : _startListening,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // void navigateToClassifyPage(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => TestPage()),
  //   );
  // }

  // void navigateToCalendarPage(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => CalendarPage()),
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   // 從 Provider 取得 LocationService 的 instance
  //   final locationService = Provider.of<LocationService>(context);

  //   return Scaffold(
  //     body: Stack(
  //       children: [
  //         // 調整 email 顯示位置
  //         Positioned(
  //           top: 50,
  //           left: 20,
  //           child: Text(
  //             user.email!,
  //             style: const TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),

  //         // 中心的歡迎文字
  //         const Center(
  //           child: Text(
  //             "Welcome!",
  //             style: TextStyle(fontSize: 24),
  //           ),
  //         ),

  //         // 顯示當前位置
  //         Positioned(
  //           top: 100,
  //           left: 20,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 '當前位置:',
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //               ),
  //               Text(
  //                 locationService.location,
  //                 style: const TextStyle(fontSize: 16),
  //               ),
  //             ],
  //           ),
  //         ),

  //         // 跳轉到 test_page
  //         Positioned(
  //           bottom: 50,
  //           left: 20,
  //           right: 20,
  //           child: ElevatedButton(
  //             onPressed: () =>
  //                 navigateToClassifyPage(context), // 跳轉到 ClassifyPage
  //             child: const Text('跳轉到分類頁面'),
  //           ),
  //         ),

  //         Positioned(
  //           bottom: 100,
  //           left: 20,
  //           right: 20,
  //           child: ElevatedButton(
  //             onPressed: () =>
  //                 navigateToCalendarPage(context), // 跳轉到 CalendarPage
  //             child: const Text('跳轉到行事曆模擬頁面'),
  //           ),
  //         ),
  //       ],
  //     ),
  //     appBar: AppBar(
  //       actions: [
  //         IconButton(
  //           onPressed: signUserOut,
  //           icon: const Icon(Icons.logout),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
