import 'package:final_project/services/ollama_service.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final OllamaApiService _ollamaApiService = OllamaApiService();
  String? _response;

  void _testConnection() async {
    final content = 'What is 2 + 2?';
    final response = await _ollamaApiService.generateText(content);
    setState(() {
      _response = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OLLAMA Connection Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _testConnection,
              child: Text('Test Connection'),
            ),
            SizedBox(height: 20),
            if (_response != null)
              Text(
                'Response: $_response',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
