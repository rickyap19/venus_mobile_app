import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/portal_page.dart';

void main() {
  runApp(const PISManagementApp());
}

class PISManagementApp extends StatelessWidget {
  const PISManagementApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIS Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/portal': (context) => const PortalPage(),
      },
    );
  }
}