import 'package:flutter/material.dart';
import 'package:bookfx/bookfx.dart';

class DiaryPage extends StatefulWidget {
  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

// promt: 使用者是一位學生，請重點放於使用者講的話，並不強調此段對話，生成30~50字的短篇日記

class _DiaryPageState extends State<DiaryPage> {
  List<String> diaryEntries = [
    "2024-11-07: \n\n明天我要去體檢，今天感覺很累。希望能準備好，讓體檢順利進行。也想放鬆一下，調整狀態，讓自己保持精力充沛。",
    "2024-09-01: \n\n今天的天氣很好，我去了公園散步。",
    "2024-09-02: \n\n今天在宿舍睡了一天，什麼都沒做...",
    "2024-09-03: \n\n晚上跟朋友們一起去看了一場電影。",
    "2024-09-04: \n\n作業做完啦，心情非常好！",
    "2024-09-05: \n\n天氣轉涼了，準備換上秋天的衣服。"
  ];

  final BookController bookController = BookController();
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/image/diary.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 210,
            left: 50,
            right: 20,
            child: Container(
              height: 470,
              child: BookFx(
                size: Size(MediaQuery.of(context).size.width * 1, 500),
                pageCount: diaryEntries.length,
                currentPage: (index) {
                  print('ccurrent');
                  return _buildDiaryPage(index);
                },
                lastCallBack: (index) {
                  print('call');
                  if (index == 0) {
                    return;
                  }
                  setState(() {});
                },
                nextPage: (index) {
                  print('next');
                  return _buildDiaryPage(index - 1);
                },
                controller: bookController,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryPage(int index) {
    return Container(
      child: Stack(
        children: [
          Positioned(
            top: 70, // 距離上方的距離
            left: 50, // 距離左側的距離
            right: 40, // 距離右側的距離
            child: Text(
              diaryEntries[index],
              style: TextStyle(
                fontSize: 18,
                fontFamily: '851Tegaki',
                color: Colors.black,
              ),
              textAlign: TextAlign.center, // 文字居中對齊
            ),
          ),
        ],
      ),
    );
  }
}
