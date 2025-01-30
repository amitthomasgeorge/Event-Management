import 'dart:convert';
import 'package:eventmanagement/Admin/Userevent.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
class Useradmindashboard extends StatefulWidget {
  const Useradmindashboard({super.key});

  @override
  State<Useradmindashboard> createState() => _UseradmindashboardState();
}

class _UseradmindashboardState extends State<Useradmindashboard> {
List Userdata=[];
late WebSocketChannel channel;

@override
  void initState() {
    super.initState();
    fetchUseradmin();
     channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));
      channel.stream.listen((data) {
      var response = json.decode(data);
      if (response['action'] == 'cancelevent' || response['action']=='cancel' || response['action']=='canceluser' || response['action']=='cancelorg') {
        setState(() {
          fetchUseradmin();
        });
      }
    });
  
  }

Future<void> fetchUseradmin() async {
  final res= await http.get(Uri.parse('http://localhost:3000/fetchUserDash'));
  if(res.statusCode==200)
  {
    setState(() {
      Userdata=json.decode(res.body);
    });
  }
  else
  {
    throw Exception('Failed to fetch\n');
  }
  print(Userdata);
}


void cancelUser(String user) {
    final message = json.encode({
      'action': 'canceluser',
      'user':user,
    });
    print(message);
    channel.sink.add(message);
  }


  @override
  void dispose() {
    super.dispose(); // Dispose Razorpay instance when widget is disposed
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: Container(
        margin: EdgeInsets.all(40),
        child: SizedBox(
          width: double.infinity,
          child: Userdata.isEmpty? Text('No User') :ListView.builder(
          itemCount: Userdata.length, // Number of items in the list
          itemBuilder: (context, index) {
            return ListTile(
              leading: IconButton(onPressed: (){
                cancelUser(Userdata[index]['username']);
              }, icon: Icon(Icons.delete)), // Optional leading icon
              title: Text(Userdata[index]['username']), // The main text of the list item
              subtitle: Text('Booked History (Click Here)'), // Optional subtitle
              trailing: Icon(Icons.arrow_forward), // Optional trailing icon
              onTap: () {
                  Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>  Userevent(username:Userdata[index]['username']),
                          ),
                        );
              },
            );
          },
              ),
        ),
      ),
    );
  }
}