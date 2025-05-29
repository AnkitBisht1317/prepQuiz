import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prepquiz/theme/theme.dart';
import 'package:prepquiz/view/mainview/get_start.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Quiz App",
      theme: AppTheme.theme,
      home: GetStart(),
    );
  }
}
