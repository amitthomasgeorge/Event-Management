import 'package:eventmanagement/Admin/dashboardadmin.dart';
import 'package:eventmanagement/Organizer/dashboard.dart';
import 'package:eventmanagement/User/dummy2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'dashboard.dart';



class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameController.text,
        "password": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final username = usernameController.text;
      // Navigate to the Dashboard page and pass the username
        if(data['results'][0]['type']=='User')
        {
            Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardUser(username: username)
        ),
        (Route<dynamic> route)=> false,
      );
        }
        else if (data['results'][0]['type']=='Organization')
        {
          Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(username: username),
        ),
        (Route<dynamic> route)=> false,
      );
      }
      else if(data['results'][0]['type']=='Admin'){
        Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboardadmin(username: username),
        ),
        (Route<dynamic> route)=> false,
      ); 
      }
    
    } else {
      final errorMessage = jsonDecode(response.body)['message'];
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Login Failed"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
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
      appBar: AppBar(title: Text("WELCOME",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),)),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(140).copyWith(right: margin,left: margin),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Align(alignment: Alignment.center, child: Text('Login',style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),)),
              const SizedBox(height: 60,),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: "Username"),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                  onPressed: () => loginUser(context),
                  child: Text("Login",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
                 ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context,'/register');
                  },
                  child: Text('Register',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}