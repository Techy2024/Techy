import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'src/views/WelcomePage.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(TechyApp());
}
