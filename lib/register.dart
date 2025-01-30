import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  String? selectedRole;

  List<String> roles=['Organization','User'];

  Future<void> registerUser() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/auth/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameController.text,
        "password": passwordController.text,
        "type":selectedRole,
        'name': nameController.text,
      }),
    );

    if (response.statusCode == 201) {
      print("User registered successfully");
      setState(() {
        usernameController.clear();
        passwordController.clear();
        Navigator.pushNamed(context, '/login');
      });
    } else {
        showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error: ${jsonDecode(response.body)['message']}"),
        content: Text('Retry'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),);
      print("Error: ${jsonDecode(response.body)['message']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double margin;
    if (screenwidth < 1200) {
      margin = 120;
    } else {
      margin = 500;
    }
    return Scaffold(
      appBar: AppBar(title: Text("Register Form",style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),)),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(140).copyWith(right: margin,left: margin),
          padding: EdgeInsets.all(20).copyWith(bottom: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                      value: selectedRole,
                      hint: const Text('Select Type'),
                      items: roles
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                          
                        });
                      },
                    ),
                    const SizedBox(height: 20,),
                     selectedRole=='Organization'? TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Organization Name"),
              ):TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "User Name")),
                const SizedBox(height: 20,),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: "Username"),
              ),const SizedBox(height: 20,),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),const SizedBox(height: 40,),
              ElevatedButton(
                onPressed: registerUser,
                child: Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}