import 'package:final_project/pages/calendar_page.dart';
import 'package:final_project/pages/login_page.dart';
import 'package:final_project/pages/test_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/services/location_service.dart'; // 引入 LocationService

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  // logout
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void navigateToClassifyPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TestPage()),
    );
  }

  void navigateToCalendarPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CalendarPage()),
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

          // 跳轉到 test_page
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () =>
                  navigateToClassifyPage(context), // 跳轉到 ClassifyPage
              child: const Text('跳轉到分類頁面'),
            ),
          ),

          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () =>
                  navigateToCalendarPage(context), // 跳轉到 CalendarPage
              child: const Text('跳轉到行事曆模擬頁面'),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
