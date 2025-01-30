import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();



  Future<void> submitdata() async
  {
       final url = Uri.parse('http://localhost:3000/submit'); // Your server URL here
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Organiser': nameController.text,
        'event': emailController.text,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Organization')),
      ),
      body: Column(
        children: [
          TextField(
            controller: nameController,
          ),
          TextField(
            controller: emailController,
          ),
          ElevatedButton(onPressed: ()=>{
            setState(() {
              submitdata();
              nameController.clear();
              emailController.clear();
            }),
          }, 
          child: Text('Submit'))
        ],
      ),
    );
  }
}