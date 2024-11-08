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

  bool _isEditable = true; // 控制是否可編輯

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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/image/setting_background.png'), // 背景圖片
            fit: BoxFit.cover, // 覆蓋整個屏幕
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 150.0), // 左右間距20，上下間距100
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7), // 白色背景，調整透明度
                borderRadius: BorderRadius.circular(10), // 圓角
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _homeController,
                      decoration: InputDecoration(
                        labelText: "住家地址",
                        labelStyle: TextStyle(color: const Color.fromARGB(255, 69, 69, 69)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(255, 150, 150, 150), width: 2.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(255, 150, 150, 150), width: 2.0),
                        ),
                      ),
                      enabled: _isEditable,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        labelText: "公司地址",
                        labelStyle: TextStyle(color: const Color.fromARGB(255, 69, 69, 69)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(255, 150, 150, 150), width: 2.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(255, 150, 150, 150), width: 2.0),
                        ),
                      ),
                      enabled: _isEditable,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _schoolController,
                      decoration: InputDecoration(
                        labelText: "學校地址",
                        labelStyle: TextStyle(color: const Color.fromARGB(255, 69, 69, 69)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(255, 150, 150, 150), width: 2.0),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: const Color.fromARGB(255, 150, 150, 150), width: 2.0),
                        ),
                      ),
                      enabled: _isEditable,
                    ),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _saveAddressData,
                          child: Text("儲存"),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isEditable = !_isEditable;
                            });
                          },
                          child: Text(_isEditable ? "取消編輯" : "編輯"),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        // 呼叫登出確認對話框
                        _showLogoutDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("登出確認"),
        content: Text("您確定要登出嗎？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("取消"),
          ),
          TextButton(
            onPressed: () {
              // 登出邏輯
              Navigator.of(context).pop();
            },
            child: Text("確定"),
          ),
        ],
      ),
    );
  }
}
