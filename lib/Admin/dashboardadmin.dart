import 'dart:convert';
import 'package:eventmanagement/Login.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Dashboardadmin extends StatefulWidget {
  final String username;
  const Dashboardadmin({super.key,required this.username});

  @override
  State<Dashboardadmin> createState() => _DashboardadminState();
}

class _DashboardadminState extends State<Dashboardadmin> {
  late WebSocketChannel channel;
   List Orgdata=[];
   List Userdata=[];

@override
  void initState() {
    super.initState();
    fetchOrg();
    fetchUser();
      channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));
      channel.stream.listen((data) {
      var response = json.decode(data);
      if (response['action'] == 'cancelevent' || response['action']=='cancel' || response['action']=='canceluser' || response['action']=='cancelorg') {
        setState(() {
          fetchOrg();
          fetchUser();
        });
      }
    });
  }


Future<void> fetchOrg() async {
  final res= await http.get(Uri.parse('http://localhost:3000/fetchOrgAdmin'));
  if(res.statusCode==200)
  {
    setState(() {
      Orgdata=json.decode(res.body);
    });
  }
  else
  {
    throw Exception('Failed to fetch\n');
  }

}

Future<void> fetchUser() async {
  final res= await http.get(Uri.parse('http://localhost:3000/fetchUserAdmin'));
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
}

 @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Welcom Admin',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),),
        actions: [
          IconButton(onPressed: ()
          {
             Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                  (Route<dynamic> route)=> false,
                );
          }, icon: Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, '/Orgdash');
                  },
                  child: Container(
                    padding: EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                  
                    ),
                    child: Column(
                      children: [
                        Text('Organizations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),),
                        Orgdata.isEmpty? Text('count'):Text('Count:${Orgdata[0]['Orgcount']}')
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    Navigator.pushNamed(context, '/Userdash');
                  },
                  child: Container(
                    padding: EdgeInsets.all(40).copyWith(right: 80,left: 80),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        Text('Users',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),),
                         Userdata.isEmpty? Text('count'):Text('Count:${Userdata[0]['Usercount']}')
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}