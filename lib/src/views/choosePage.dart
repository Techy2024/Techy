import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 確保導入 Firestore 的包
import 'HomePage.dart';

class CubeMenuPage extends StatefulWidget {
  @override
  _CubeMenuPageState createState() => _CubeMenuPageState();
}

class _CubeMenuPageState extends State<CubeMenuPage> {
  PageController _pageController = PageController();
  
  // 更新您的 GIF 文件列表以匹配所需的名稱
  List<String> gifAssets = [
    'assets/gif/INTJ/wave_hand.gif',
    'assets/gif/ISTP/wave_hand.gif',
    'assets/gif/ENFJ/wave_hand.gif',
    'assets/gif/ESFP/wave_hand.gif',
  ];

  List<String> characterNames = [
    'INTJ',
    'ISTP',
    'ENFJ',
    'ESFP',
  ];

  List<Color> backgroundColors = [
    const Color.fromARGB(255, 194, 205, 227),
    const Color.fromARGB(255, 197, 216, 193),
    const Color.fromARGB(255, 236, 235, 208),
    const Color.fromARGB(255, 228, 215, 200),
  ];

  List<String> characterInfos = [
    '角色簡介:\n 姓名: A \n身高: 15cm',
    '角色簡介:\n 姓名: B \n身高: 18cm',
    '角色簡介:\n 姓名: C \n身高: 17.5cm',
    '角色簡介:\n 姓名: D \n身高: 16.5cm',
  ];

  void _nextPage() {
    if (_pageController.page != null && _pageController.page! < gifAssets.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_pageController.page != null && _pageController.page! > 0) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> saveCharacterToFirestore(String characterName) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 儲存到 "User_Info" 集合
    await firestore.collection('Users_Info').add({
      'techy_type': characterName, // 儲存選中的角色名稱
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: gifAssets.length,
              itemBuilder: (context, index) {
                return CubePage(
                  gifAsset: gifAssets[index], // 使用 GIF 文件
                  backgroundColor: backgroundColors[index],
                  characterInfo: characterInfos[index],
                  onButtonPressed: () async {
                    // 在這裡儲存角色到 Firestore
                    await saveCharacterToFirestore(characterNames[index]);
                    // 導航到 HomePage
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => HomePage()),
                    );
                  },
                );
              },
            ),
            // 左邊箭頭
            Positioned(
              left: 16,
              top: MediaQuery.of(context).size.height / 2 - 24,
              child: GestureDetector(
                onTap: _previousPage,
                child: Icon(
                  CupertinoIcons.left_chevron,
                  size: 48,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            // 右邊箭頭
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height / 2 - 24,
              child: GestureDetector(
                onTap: _nextPage,
                child: Icon(
                  CupertinoIcons.right_chevron,
                  size: 48,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CubePage extends StatelessWidget {
  final String gifAsset;
  final Color backgroundColor;
  final String characterInfo;
  final VoidCallback onButtonPressed;

  CubePage({required this.gifAsset, required this.backgroundColor, required this.characterInfo, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '左右滑動選擇',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            SizedBox(
              width: 300,
              height: 300,
              child: Image.asset(
                gifAsset, // 使用 GIF 文件
                fit: BoxFit.cover, // 設置適合的顯示方式
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                characterInfo,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            SizedBox(height: 40),
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: CupertinoButton(
                  child: Icon(CupertinoIcons.check_mark),
                  onPressed: onButtonPressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
