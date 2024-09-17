import 'package:final_project/pages/location_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  // logout
  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    // 返回到登入頁面或其他地方，這裡假設返回到上一頁
  }

  void navigateToLocationPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 使用 Positioned 調整 email 的位置
          Positioned(
            top: 50, // 從上方的距離
            left: 20, // 從左側的距離
            child: Text(
              user.email!,
              style: const TextStyle(
                fontSize: 18, // 調整字體大小
                fontWeight: FontWeight.bold, // 使用粗體字
              ),
            ),
          ),

          // 中心的歡迎文字
          const Center(
            child: Text(
              "Welcome!",
              style: TextStyle(fontSize: 24),
            ),
          ),

          // 按鈕放在底部，讓使用者導向經緯度頁面
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () => navigateToLocationPage(context),
                child: const Text('Go to Location Page'),
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => signUserOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
