import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DefaultLocationPage extends StatefulWidget {
  @override
  _DefaultLocationPageState createState() => _DefaultLocationPageState();
}

class _DefaultLocationPageState extends State<DefaultLocationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _homeController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDefaultAddresses();
  }

  Future<void> _loadDefaultAddresses() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('UserID').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic>? data =
            userDoc.data() as Map<String, dynamic>?;
        if (data != null && data['default_addresses'] != null) {
          setState(() {
            _homeController.text = data['default_addresses']['home'] ?? '';
            _companyController.text =
                data['default_addresses']['company'] ?? '';
            _schoolController.text =
                data['default_addresses']['school'] ?? '';
          });
        }
      }
    }
  }

  Future<void> _showInputDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('設定預設地址'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _homeController,
                  decoration: InputDecoration(labelText: '住家地址'),
                ),
                TextField(
                  controller: _companyController,
                  decoration: InputDecoration(labelText: '公司地址'),
                ),
                TextField(
                  controller: _schoolController,
                  decoration: InputDecoration(labelText: '學校地址'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('儲存'),
              onPressed: () {
                _saveDefaultLocations();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDefaultLocations() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('UserID').doc(user.uid).set({
        'default_addresses': {
          'home': _homeController.text,
          'company': _companyController.text,
          'school': _schoolController.text,
        }
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('預設地址已儲存')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('無法獲取使用者資訊')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('預設地址設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 顯示當前的預設地址
            ListTile(
              title: Text('住家地址'),
              subtitle: Text(_homeController.text.isEmpty
                  ? '未設定'
                  : _homeController.text),
            ),
            ListTile(
              title: Text('公司地址'),
              subtitle: Text(_companyController.text.isEmpty
                  ? '未設定'
                  : _companyController.text),
            ),
            ListTile(
              title: Text('學校地址'),
              subtitle: Text(_schoolController.text.isEmpty
                  ? '未設定'
                  : _schoolController.text),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showInputDialog,
              child: Text('設定或修改地址'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _homeController.dispose();
    _companyController.dispose();
    _schoolController.dispose();
    super.dispose();
  }
}
