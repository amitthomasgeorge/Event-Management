
import 'package:eventmanagement/Admin/Organizationadmin.dart';
import 'package:eventmanagement/Admin/Useradmin.dart';
import 'package:eventmanagement/Admin/dashboardadmin.dart';
import 'package:eventmanagement/Login.dart';
import 'package:eventmanagement/Organizer/dashboard.dart';
import 'package:eventmanagement/User/bookings.dart';
import 'package:eventmanagement/User/EventDetail.dart';
import 'package:eventmanagement/User/dummy2.dart';
import 'package:eventmanagement/register.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        '/eventdetail': (context) => EventDetail(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/Orgdash': (context) => Orgdashboard(),
        '/Userdash': (context) => Useradmindashboard(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  LoginPage(),
    );
  }
}

