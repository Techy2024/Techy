import 'package:final_project/pages/test_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/services/location_service.dart'; // 引入 LocationService

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  // logout
  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
    // 返回到登入頁面或其他地方，這裡假設返回到上一頁
    Navigator.pop(context);
  }

  void navigateToTestPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TestPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 從 Provider 取得 LocationService 的 instance
    final locationService = Provider.of<LocationService>(context);

    return Scaffold(
      body: Stack(
        children: [
          // 調整 email 顯示位置
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              user.email!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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

          // 顯示當前位置
          Positioned(
            top: 100,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '當前位置:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  locationService.location,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // 跳轉道 test_page
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => navigateToTestPage(context), // 跳轉到 TestPage
              child: const Text('跳轉到測試頁面'),
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
