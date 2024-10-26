import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class CubeMenuPage extends StatefulWidget {
  @override
  _CubeMenuPageState createState() => _CubeMenuPageState();
}

class _CubeMenuPageState extends State<CubeMenuPage>
    with WidgetsBindingObserver {
  PageController _pageController = PageController();

  List<String> gifAssets = [
    'lib/assets/gif/INTJ/wave_hand.gif',
    'lib/assets/gif/ISTP/wave_hand.gif',
    'lib/assets/gif/ENFJ/wave_hand.gif',
    'lib/assets/gif/ESFP/wave_hand.gif',
  ];

  List<String> characterNames = ['INTJ', 'ISTP', 'ENFJ', 'ESFP'];

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this); // 移除觀察者
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.page != null &&
        _pageController.page! < gifAssets.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_pageController.page != null && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> saveCharacterToFirestore(String characterName) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      await firestore.collection('UserID').doc(uid).set({
        'character_type': characterName,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: gifAssets.length,
            itemBuilder: (context, index) {
              return CubePage(
                gifAsset: gifAssets[index],
                backgroundColor: backgroundColors[index],
                characterInfo: characterInfos[index],
                onButtonPressed: () async {
                  await saveCharacterToFirestore(characterNames[index]);
                  if (mounted) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => HomePage()),
                    );
                  }
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
    );
  }
}

class CubePage extends StatelessWidget {
  final String gifAsset;
  final Color backgroundColor;
  final String characterInfo;
  final VoidCallback onButtonPressed;

  CubePage({
    required this.gifAsset,
    required this.backgroundColor,
    required this.characterInfo,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '左右滑動選擇',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            SizedBox(
              width: 300,
              height: 300,
              child: Image.asset(
                gifAsset,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                characterInfo,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            const SizedBox(height: 40),
            CupertinoButton(
              child: const Icon(CupertinoIcons.check_mark),
              onPressed: onButtonPressed,
            ),
          ],
        ),
      ),
    );
  }
}
