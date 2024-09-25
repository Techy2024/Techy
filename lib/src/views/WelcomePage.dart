import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'ChoosePage.dart';

class TechyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: WelcomeHomePage(),
    );
  }
}

class WelcomeHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: GestureDetector(
        onTap: () {
          // 使用PageRouteBuilder自定義轉換效果
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 500), // 轉換持續時間
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // 定義轉換效果
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: child,
                );
              },
              pageBuilder: (context, animation, secondaryAnimation) {
                return CubeMenuPage();
              },
            ),
          );
        },
        child: Container(
          color: Color.fromARGB(24, 200, 205, 255),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Image.asset(
                    'assets/gif/ENFJ/shake_head.gif', // 使用 GIF 文件
                    fit: BoxFit.cover, // 设置适合的显示方式
                  ),
                ),
                SizedBox(height: 40), // 添加间距
                Text(
                  "點擊空白處進入應用程式",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}