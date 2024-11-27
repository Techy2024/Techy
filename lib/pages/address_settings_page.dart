import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project/pages/home_page.dart'; // Import home_page.dart
import 'package:final_project/pages/auth_page.dart'; // Import auth_page.dart

class AddressSettingsPage extends StatefulWidget {
  @override
  _AddressSettingsPageState createState() => _AddressSettingsPageState();
}

class _AddressSettingsPageState extends State<AddressSettingsPage> {
  final _homeController = TextEditingController();
  final _companyController = TextEditingController();
  final _schoolController = TextEditingController();
  bool _isEditable = false; // 用來控制是否可以編輯

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
    }
  }

  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditable = !_isEditable;
    });
  }

  Future<void> _showLogoutDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '確認登出',
            style: TextStyle(fontSize: 18),
          ),
          content: Text(
            '您確定要登出嗎？',
            style: TextStyle(fontSize: 12),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
              },
              child: Text('取消', style: TextStyle(fontSize: 14)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
                _signOut(); // 執行登出
                // Navigate to the Auth Page after logging out
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()), // Navigate to Auth Page
                );
              },
              child: Text('確認', style: TextStyle(fontSize: 14)),
            ),
          ],
        );
      },
    );
  }

  void _goBackToHomePage() {
    // Navigate to Home Page when "返回" is tapped
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), // Navigate to Home Page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/image/setting_background.png'), // 背景圖片
            fit: BoxFit.cover, // 覆蓋整個屏幕
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 150.0), // 左右間距20，上下間距100
          child: Center( // 將內容居中顯示
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7), // 設定背景色為白色，並調整透明度
                borderRadius: BorderRadius.circular(10), // 可選：為了更圓滑的邊角
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0), // 為背景框內的內容添加Padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                  crossAxisAlignment: CrossAxisAlignment.center, // 水平居中
                  children: [
                    TextField(
                      controller: _homeController,
                      decoration: InputDecoration(
                        labelText: "住家地址",
                        labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 69, 69, 69), // 設定字體顏色
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 150, 150, 150), // 設定底線顏色
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 150, 150, 150), // 設定獲得焦點時的底線顏色
                            width: 2.0,
                          ),
                        ),
                      ),
                      enabled: _isEditable, // 控制是否可編輯
                    ),
                    SizedBox(height: 20), // 增加空白區段，調整大小
                    TextField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        labelText: "公司地址",
                        labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 69, 69, 69), // 設定字體顏色
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 150, 150, 150), // 設定底線顏色
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 150, 150, 150), // 設定獲得焦點時的底線顏色
                            width: 2.0,
                          ),
                        ),
                      ),
                      enabled: _isEditable, // 控制是否可編輯
                    ),
                    SizedBox(height: 20), // 增加空白區段，調整大小
                    TextField(
                      controller: _schoolController,
                      decoration: InputDecoration(
                        labelText: "學校地址",
                        labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 69, 69, 69), // 設定字體顏色
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 150, 150, 150), // 設定底線顏色為
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color.fromARGB(255, 150, 150, 150), // 設定獲得焦點時的底線顏色
                            width: 2.0,
                          ),
                        ),
                      ),
                      enabled: _isEditable, // 控制是否可編輯
                    ),
                    SizedBox(height: 50), // 增加更大的空白區段，調整按鈕間的間距
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 水平居中
                      children: [
                        ElevatedButton(
                          onPressed: _isEditable ? _saveAddressData : _goBackToHomePage, // 儲存或返回
                          child: Text(_isEditable ? "儲存" : "返回"),
                        ),
                        SizedBox(width: 20), // 增加兩個按鈕之間的間距
                        ElevatedButton(
                          onPressed: _toggleEditMode, // 觸發編輯模式的切換
                          child: Text(_isEditable ? "取消編輯" : "編輯"),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                    IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        _showLogoutDialog(); // 顯示登出確認對話框
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
}