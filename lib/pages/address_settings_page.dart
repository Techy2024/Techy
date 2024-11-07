import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressSettingsPage extends StatefulWidget {
  @override
  _AddressSettingsPageState createState() => _AddressSettingsPageState();
}

class _AddressSettingsPageState extends State<AddressSettingsPage> {
  final _homeController = TextEditingController();
  final _companyController = TextEditingController();
  final _schoolController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddressData();
  }

  Future<void> _loadAddressData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('UserID')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _homeController.text = data['home'] ?? '';
          _companyController.text = data['company'] ?? '';
          _schoolController.text = data['school'] ?? '';
        });
      }
    }
  }
  Future<void> _saveAddressData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('UserID')
          .doc(currentUser.uid)
          .set({
        'home': _homeController.text,
        'company': _companyController.text,
        'school': _schoolController.text,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("地址已儲存")),
      );

      // 儲存完成後返回首頁
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("設定地址")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _homeController,
              decoration: InputDecoration(labelText: "住家地址"),
            ),
            TextField(
              controller: _companyController,
              decoration: InputDecoration(labelText: "公司地址"),
            ),
            TextField(
              controller: _schoolController,
              decoration: InputDecoration(labelText: "學校地址"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveAddressData,
              child: Text("儲存"),
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
