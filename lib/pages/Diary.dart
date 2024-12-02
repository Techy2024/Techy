import 'package:flutter/material.dart';
import 'package:bookfx/bookfx.dart';
import 'package:provider/provider.dart';
import '../services/diary_service.dart';

class DiaryPage extends StatefulWidget {
  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final BookController bookController = BookController();

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
              child: Consumer<DiaryService>(
                builder: (context, diaryService, child) {
                  return BookFx(
                    size: Size(MediaQuery.of(context).size.width * 1, 500),
                    pageCount: diaryService.diaryEntries.length,
                    currentPage: (index) {
                      return _buildDiaryPage(context, index);
                    },
                    lastCallBack: (index) {
                      setState(() {});
                    },
                    nextPage: (index) {
                      return _buildDiaryPage(context, index - 1);
                    },
                    controller: bookController,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryPage(BuildContext context, int index) {
    final diaryEntries = Provider.of<DiaryService>(context).diaryEntries;

    return Container(
      child: Stack(
        children: [
          Positioned(
            top: 70,
            left: 50,
            right: 40,
            child: Text(
              diaryEntries[index],
              style: TextStyle(
                fontSize: 18,
                fontFamily: '851Tegaki',
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}