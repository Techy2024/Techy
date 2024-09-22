import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  // 更改這裡：使用 List<Map<String, dynamic>> 而不是 List<String>
  final List<Map<String, dynamic>> _notes = [];
  final TextEditingController _controller = TextEditingController();

  void _addNote() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        // 添加一個 Map 而不是一個 String
        _notes.add({
          'text': _controller.text,
          'isChecked': false,
        });
        _controller.clear();
      });
    }
  }

  void _removeNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  void _toggleCheck(int index) {
    setState(() {
      _notes[index]['isChecked'] = !_notes[index]['isChecked'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/ToDoList2.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 250, // 調整到所需的位置
            left: 150, // 調整到所需的位置
            child: Text(
              'To Do List',  // 這裡可以填入您想顯示的文本
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
                          _notes[index]['text'],  // 使用 'text' 鍵來獲取文本
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
                      GestureDetector(
                        onTap: () => _removeNote(index),
                        child: Icon(CupertinoIcons.clear_circled, size: 20),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 60,
            left: 50,
            right: 50,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _controller,
                    placeholder: "Write your note here...",
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.systemGrey, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                CupertinoButton(
                  child: Icon(CupertinoIcons.add),
                  onPressed: _addNote,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}