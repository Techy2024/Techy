import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'HomePage.dart';

class CubeMenuPage extends StatefulWidget {
  @override
  _CubeMenuPageState createState() => _CubeMenuPageState();
}

class _CubeMenuPageState extends State<CubeMenuPage> {
  PageController _pageController = PageController();

  List<String> glbAssets = [
    'assets/glb/sheen_chair.glb',
    'assets/glb/sheen_chair.glb',
    'assets/glb/sheen_chair.glb',
    'assets/glb/sheen_chair.glb',
  ];

  List<Color> backgroundColors = [
    const Color.fromARGB(255, 247, 179, 179),
    const Color.fromARGB(255, 149, 197, 174),
    const Color.fromARGB(255, 152, 171, 204),
    Color.fromARGB(255, 231, 218, 160),
  ];

  List<String> characterInfos = [
    '角色簡介:\n 姓名: A /n身高: 170cm',
    '角色簡介:\n 姓名: B /n身高: 180cm',
    '角色簡介:\n 姓名: C /n身高: 175cm',
    '角色簡介:\n 姓名: D /n身高: 165cm',
  ];

  void _nextPage() {
    if (_pageController.page != null && _pageController.page! < glbAssets.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousPage() {
    if (_pageController.page != null && _pageController.page! > 0) {
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: glbAssets.length,
              itemBuilder: (context, index) {
                return CubePage(
                  glbAsset: glbAssets[index],
                  backgroundColor: backgroundColors[index],
                  characterInfo: characterInfos[index],
                  onButtonPressed: () {
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
  final String glbAsset;
  final Color backgroundColor;
  final String characterInfo;
  final VoidCallback onButtonPressed;

  CubePage({required this.glbAsset, required this.backgroundColor, required this.characterInfo, required this.onButtonPressed});

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
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            SizedBox(
              width: 300,
              height: 300,
              child: Flutter3DViewer(
                src: glbAsset,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                characterInfo,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
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
