import 'package:flutter/material.dart';
import 'package:product_crud/login.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_core/firebase_core.dart';

void main() async {
  //To initialize firebase core
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'flutter demo',
      home: Login(),
    );
  }
}
