import 'package:final_project/pages/auth_page.dart';
import 'package:final_project/services/location_service.dart';
import 'package:final_project/services/diary_service.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => DiaryService()),
      ],
      child: const MaterialApp(
        debugShowMaterialGrid: false,
        home: AuthPage(),
      ),
    );
  }
}
