import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api/ollama_llama3.dart'; 

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String? _apiResponse; // API 的回應
  final OllamaApiService apiService = OllamaApiService();
  void _sendMessage(BuildContext context) async {
    print("Sending message...");
    final message = _controller.text;
    if (message.isNotEmpty) {
      // 调用 API 并获得结果
      final response = await apiService.generateText(message);
      setState(() {
        _apiResponse = response; // 直接將 API 返回的內容設置為回應
        print('_apiResponse: $_apiResponse');

      });
      _controller.clear(); // 发送后清空输入框
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Home Page"),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 顯示 API 回應的框
          if (_apiResponse != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _apiResponse!,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          // 顯示圖片按鈕並導航
          Positioned(
            top: 200,
            right: 50,
            child: GestureDetector(
              onTap: () => _navigateToNewPage(context, 'Note'),
              child: Image.asset('assets/image/note.png', width: 100, height: 100),
            ),
          ),
          Positioned(
            top: 250,
            left: 50,
            child: GestureDetector(
              onTap: () => _navigateToNewPage(context, 'Calendar'),
              child: Image.asset('assets/image/calendar.png', width: 100, height: 100),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 150,
            child: GestureDetector(
              onTap: () => _navigateToNewPage(context, 'Diary'),
              child: Image.asset('assets/image/diary.png', width: 100, height: 100),
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
                    width: 250,
                    child: CupertinoTextField(
                      controller: _controller,
                      placeholder: "Type a message",
                      onSubmitted: (value) => _sendMessage(context),
                    ),
                  ),
                  CupertinoButton(
                    child: Icon(CupertinoIcons.paperplane),
                    onPressed: () => _sendMessage(context),
                  ),
                ],
              ),
            ),
          ),
        ],
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
