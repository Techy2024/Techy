import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/services/location_service.dart'; // 引入 LocationService

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 從 Provider 取得 LocationService 的實例
    final locationService = Provider.of<LocationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '這是測試頁面',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            const Text(
              '當前位置:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              locationService.location, // 顯示從 LocationService 中取得的位置信息
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 返回上一頁
              },
              child: const Text('返回上一頁'),
            ),
          ],
        ),
      ),
    );
  }
}
