import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

class Userevent extends StatefulWidget {
  final String username;
  const Userevent({super.key,required this.username});

  @override
  State<Userevent> createState() => _UsereventState();
}

class _UsereventState extends State<Userevent> {
late WebSocketChannel channel;
List Eventdata=[];

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

void cancelTicket(int id,String user,int bid) {
    final message = json.encode({
      'action': 'cancel',
      'id': id,
      'user':user,
      'bid':bid,
    });
    print(message);
    channel.sink.add(message);
  }

  Future<void> fetchUseradmin() async {
    String username=widget.username;
  final res= await http.get(Uri.parse('http://localhost:3000/fetchUserevent?username=$username'));
  if(res.statusCode==200)
  {
    setState(() {
      Eventdata=json.decode(res.body);
    });
  }
  else
  {
    throw Exception('Failed to fetch\n');
  }
print(Eventdata);
}
 @override
  void dispose() {
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User\'s Booked History',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: Container(
        margin: EdgeInsets.all(40),
        child: SizedBox(
          width: double.infinity,
          child: Eventdata.isEmpty? Text('No Booked Events') :ListView.builder(
          itemCount: Eventdata.length, // Number of items in the list
          itemBuilder: (context, index) {
            return ListTile(
              leading: IconButton(onPressed: (){
                cancelTicket(Eventdata[index]['eventid'], widget.username,Eventdata[index]['bid']);
              }, icon: Icon(Icons.delete)), // Optional leading icon
              title: Text(Eventdata[index]['eventname']), // The main text of the list item
              subtitle: Text('Booked'), // Optional subtitle
              trailing: Icon(Icons.arrow_forward), // Optional trailing icon
              onTap: () {
              },
            );
          },
          ),
        ),
      ),
    );
  }
}