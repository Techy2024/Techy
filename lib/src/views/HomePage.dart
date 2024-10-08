import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; 
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/ollama_llama3.dart'; 
import 'Note.dart'; 
import 'Calendar.dart';
import 'Diary.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _gifPath = 'assets/gif/ENFJ/shake_head.gif';
  final TextEditingController _controller = TextEditingController();
  String? _apiResponse; // API 的回應
  final OllamaApiService apiService = OllamaApiService();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0.0;

    @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    print('init: $_speechEnabled');
    setState(() {});
  }

  void _startListening() async {
    print('start...');
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'zh_CN', // 中文
    );
    setState(() {
      _gifPath = 'assets/gif/ENFJ/wave_hand.gif';
      _confidenceLevel = 0;
    });
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
    final event = await apiService.recordEvent(recognizedWords);
    setState(() {
      _gifPath = 'assets/gif/ENFJ/shake_head.gif';
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
        // print('_apiResponse: $_apiResponse');
        _gifPath = 'assets/gif/ENFJ/jump.gif'; // 更改 GIF 路徑
      });
      _controller.clear(); // 发送后清空输入框

      // 三秒后恢复原始 GIF
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _apiResponse = null;
          _gifPath = 'assets/gif/ENFJ/shake_head.gif'; // 恢复原始 GIF 路径
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(

      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image/home.png"),
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
                    color: const Color.fromARGB(255, 227, 227, 227).withOpacity(0.8),
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
                child: Image.asset(_gifPath),  // 加載 GIF
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
                    CupertinoPageRoute(builder: (context) => NotePage()), // 跳转到 NotePage
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
                        CupertinoPageRoute(builder: (context) => NotePage()), // 跳转到 NotePage
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
                    CupertinoPageRoute(builder: (context) => CalendarPage()), // 直接跳轉到 CalendarPage
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
                        CupertinoPageRoute(builder: (context) => CalendarPage()), // 直接跳转页面
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
                  child: Container( // 替換掉 CupertinoButton，使用單純的 Container
                    decoration: BoxDecoration(
                      color: Colors.transparent, // 你可以設定顏色或透明
                    ),
                  ),
                ),
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
                          color: const Color.fromARGB(255, 194, 194, 194).withOpacity(0.8), // 設置底色
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
                        _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                      ),
                      onPressed: _speechToText.isListening ? _stopListening : _startListening,
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
  void _navigateToNewPage(BuildContext context, String pageName) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => NewPage(pageName: pageName)),
    );
  }
}

class NewPage extends StatelessWidget {
  final String pageName;

  NewPage({required this.pageName});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(pageName),
      ),
      child: Center(
        child: Text('$pageName page'),
      ),
    );
  }
}
