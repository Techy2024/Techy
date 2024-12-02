import 'package:flutter/material.dart';
import 'package:bookfx/bookfx.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
                  return StreamBuilder<QuerySnapshot>(
                    stream: diaryService.diaryStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Something went wrong'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final diaries = snapshot.data?.docs ?? [];
                      
                      return BookFx(
                        size: Size(MediaQuery.of(context).size.width * 1, 500),
                        pageCount: diaries.length,
                        currentPage: (index) {
                          return _buildDiaryPage(context, diaries[index]);
                        },
                        lastCallBack: (index) {
                          setState(() {});
                        },
                        nextPage: (index) {
                          return _buildDiaryPage(context, diaries[index - 1]);
                        },
                        controller: bookController,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryPage(BuildContext context, DocumentSnapshot diary) {
    final date = diary['date'] as String;
    final content = diary['content'] as String;
    
    return Container(
      child: Stack(
        children: [
          Positioned(
            top: 70,
            left: 50,
            right: 40,
            child: Text(
              "$date:\n\n$content",
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