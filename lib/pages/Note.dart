import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 確保導入 Firestore 的包

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final List<Map<String, dynamic>> _notes = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotesFromFirestore(); // 加載資料
  }

  Future<void> _loadNotesFromFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      // 獲取 List 集合中 tag=2 的資料
      QuerySnapshot snapshot = await firestore
          .collection('UserID')
          .doc(uid)
          .collection('List')
          .where('tag', isEqualTo: 2)
          .get();

      // 將每個文檔的資料轉換為所需格式並添加到 _notes
      for (var doc in snapshot.docs) {
        String date = doc['date'];
        String name = doc['name'];
        String noteText = '$date: $name'; // 格式化字符串

        setState(() {
          _notes.add({
            'text': noteText,
            'isChecked': false,
          });
        });
      }
    }
  }

  void _addNote() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _notes.add({
          'text': _controller.text,
          'isChecked': false,
        });
        _controller.clear();
      });
    }
  }

  void _toggleCheck(int index) {
    setState(() {
      _notes[index]['isChecked'] = !_notes[index]['isChecked'];
    });
  }

  Future<void> _deleteCheckedNotes() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (var note in _notes) {
      if (note['isChecked']) {
        // 根據 note['text'] 解析出 date 和 name
        String noteText = note['text'];
        List<String> parts = noteText.split(': ');
        String date = parts[0];
        String name = parts[1];

        // 刪除 Firestore 中對應的資料
        QuerySnapshot querySnapshot = await firestore
            .collection('List')
            .where('date', isEqualTo: date)
            .where('name', isEqualTo: name)
            .get();

        for (var doc in querySnapshot.docs) {
          await firestore.collection('List').doc(doc.id).delete();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _deleteCheckedNotes(); // 刪除被檢查的筆記
        return true; // 返回 true 以允許導航
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'lib/assets/image/ToDoList2.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 250,
              left: 150,
              child: Text(
                'To Do List',
                style: TextStyle(
                  fontSize: 24,
                  color: const Color.fromARGB(255, 90, 87, 87),
                  fontFamily: '851Tegaki',
                ),
              ),
            ),
            Positioned(
              top: 270,
              left: 90,
              right: 70,
              bottom: 150,
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleCheck(index),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _notes[index]['isChecked']
                                ? Icon(Icons.check, size: 16)
                                : null,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _notes[index]['text'],
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: '851Tegaki',
                              decoration: _notes[index]['isChecked']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
