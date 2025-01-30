import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:eventmanagement/Admin/Orgevent.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Orgdashboard extends StatefulWidget {
  const Orgdashboard({super.key});

  @override
  State<Orgdashboard> createState() => _OrgdashboardState();
}

class _OrgdashboardState extends State<Orgdashboard> {
List Orgdata=[];
late WebSocketChannel channel;
@override
  void initState() {
    super.initState();
    fetchOrg();
      channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));
      channel.stream.listen((data) {
      var response = json.decode(data);
      print(response);
      if (response['action'] == 'cancelevent' || response['action']=='cancel' || response['action']=='canceluser' || response['action']=='cancelorg') {
        setState(() {
          fetchOrg();
        });
      }
    });
  }

void cancelOrg(String user,String Organiser) {
    final message = json.encode({
      'action': 'cancelorg',
      'user':user,
      'Organiser':Organiser,
    });
    print(message);
    channel.sink.add(message);
  }

Future<void> fetchOrg() async {
  final res= await http.get(Uri.parse('http://localhost:3000/fetchOrganization'));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizers',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: Container(
        margin: EdgeInsets.all(40),
        child: SizedBox(
          width: double.infinity,
          child: Orgdata.isEmpty? Text('No Registered Organizers') :ListView.builder(
          itemCount: Orgdata.length, // Number of items in the list
          itemBuilder: (context, index) {
            return ListTile(
              leading: IconButton(onPressed: (){
                cancelOrg(Orgdata[index]['username'],Orgdata[index]['Organiser']);
              }, icon: Icon(Icons.delete)), // Optional leading icon
              title: Text(Orgdata[index]['Organiser']), // The main text of the list item
              subtitle: Text('Event Organizer'), // Optional subtitle
              trailing: Icon(Icons.arrow_forward), // Optional trailing icon
              onTap: () {
                Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>  Orgevent(username:Orgdata[index]['username']),
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