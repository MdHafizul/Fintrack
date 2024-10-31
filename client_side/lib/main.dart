import 'package:expensetracker/pages/splashscreen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'service/local_storage_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageApi().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
