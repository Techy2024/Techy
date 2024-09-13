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
          // 顯示 API 回應的框
          if (_apiResponse != null)
            Positioned(
              top: 100,
              left: 50,
              right: 50,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 220, 220, 220).withOpacity(0.8),
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
              child: Image.asset('assets/image/note/Blue.png', width: 50),
            ),
          ),
          Positioned(
            top: 250,
            right: 30,
            child: GestureDetector(
              onTap: () => _navigateToNewPage(context, 'Note'),
              child: Image.asset('assets/image/note/Green.png', width: 50),
            ),
          ),
          Positioned(
            top: 250,
            right: 100,
            child: GestureDetector(
              onTap: () => _navigateToNewPage(context, 'Note'),
              child: Image.asset('assets/image/note/Pink.png', width: 50),
            ),
          ),

          Positioned(
            bottom: 100,
            right: 30,
            child: GestureDetector(
              child: Image.asset('assets/image/Table.png', width: 250),
            ),
          ),
          Positioned(
            top: 230,
            left: 10,
            child: GestureDetector(
              onTap: () => _navigateToNewPage(context, 'Calendar'),
              child: Image.asset('assets/image/calendar/Calendar.png', width: 200),
            ),
          ),
          Positioned(
            bottom: 270,
            right: 50,
            child: GestureDetector(
              onTap: () => _navigateToNewPage(context, 'Diary'),
              child: Image.asset('assets/image/Diary.png', width: 100),
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
