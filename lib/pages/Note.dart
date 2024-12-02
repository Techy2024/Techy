import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _notes = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _blinkController;
  bool _isScrollable = false;
  bool _isOverflowing = false;

  @override
  void initState() {
    super.initState();
    _loadNotesFromFirestore();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNotesFromFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      QuerySnapshot snapshot = await firestore
          .collection('UserID')
          .doc(uid)
          .collection('List')
          .where('tag', isEqualTo: 2)
          .get();

      setState(() {
        _notes.clear();
        for (var doc in snapshot.docs) {
          _notes.add({
            'text': doc['name'],
            'isChecked': false,
          });
        }
        _checkScrollability();
      });
    }
  }

  void _checkScrollability() {
    setState(() {
      _isScrollable = _notes.length > 5;
      _isOverflowing = _scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0;
    });
  }

  Future<void> _addNote() async {
    if (_controller.text.isNotEmpty) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String uid = currentUser.uid;

        await firestore.collection('UserID').doc(uid).collection('List').add({
          'date': '',
          'start_time': '',
          'end_time': '',
          'location': '',
          'name': _controller.text,
          'tag': 2,
        });

        setState(() {
          _notes.add({
            'text': _controller.text,
            'isChecked': false,
          });
          _controller.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New todo item added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        _checkScrollability();
      }
    }
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Todo'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter event name'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _controller.clear();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _addNote();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleCheck(int index) {
    setState(() {
      _notes[index]['isChecked'] = !_notes[index]['isChecked'];
    });
  }

  void _showDeleteConfirmDialog() {
    int checkedCount = _notes.where((note) => note['isChecked']).length;

    if (checkedCount == 0) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete $checkedCount selected todo item(s)?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteCheckedNotes();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCheckedNotes() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String uid = currentUser.uid;

      for (var note in _notes.where((note) => note['isChecked']).toList()) {
        QuerySnapshot querySnapshot = await firestore
            .collection('UserID')
            .doc(uid)
            .collection('List')
            .where('name', isEqualTo: note['text'])
            .where('tag', isEqualTo: 2)
            .get();

        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }
      }

      setState(() {
        _notes.removeWhere((note) => note['isChecked']);
      });

      _checkScrollability();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete successful!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          for (var note in _notes) {
            note['isChecked'] = false;
          }
        });
        return true;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddNoteDialog,
          child: Icon(Icons.add),
        ),
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
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'To Do List',
                    style: TextStyle(
                      fontSize: 24,
                      color: const Color.fromARGB(255, 90, 87, 87),
                      fontFamily: '851Tegaki',
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Positioned(
              top: 290,
              left: 90,
              right: 70,
              bottom: 180,
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  _checkScrollability();
                  return true;
                },
                child: ListView.builder(
                  controller: _scrollController,
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
            ),
            if (_isOverflowing)
              Positioned(
                bottom: 150,
                left: 0,
                right: 0,
                child: Center(
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.2, end: 1.0)
                        .animate(_blinkController),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 40,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: _notes.any((note) => note['isChecked'])
                    ? ElevatedButton(
                        onPressed: _showDeleteConfirmDialog,
                        child: Text('Delete Selected Items'),
                      )
                    : SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
