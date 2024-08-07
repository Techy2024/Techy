import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  void _navigateToNewPage(BuildContext context, String pageName) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => NewPage(pageName: pageName)),
    );
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
          // todo:  做成透明的點擊框
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
              onTap: () => _navigateToNewPage(context, 'diary'),
              child: Image.asset('assets/image/diary.png', width: 100, height: 100),
            ),
          ),
        ],
      ),
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
