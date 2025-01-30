import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
class Orgevent extends StatefulWidget {
  final String username;
  const Orgevent({super.key,required this.username});

  @override
  State<Orgevent> createState() => _OrgeventState();
}

class _OrgeventState extends State<Orgevent> {
late WebSocketChannel channel;
List Orgdata=[];

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
void cancelEvent(int id,String user) {
    final message = json.encode({
      'action': 'cancelevent',
      'id': id,
      'user':user,
    });
    print(message);
    channel.sink.add(message);
  }

  Future<void> fetchOrg() async {
    String username=widget.username;
  final res= await http.get(Uri.parse('http://localhost:3000/fetchOrgevent?username=$username'));
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
print(Orgdata);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organizer\'s Event',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),),
      ),
      body: Container(
        margin: EdgeInsets.all(40),
        child: SizedBox(
          width: double.infinity,
          child: Orgdata.isEmpty? Text('Failed to fetch') :ListView.builder(
          itemCount: Orgdata.length, // Number of items in the list
          itemBuilder: (context, index) {
            return ListTile(
              leading: IconButton(onPressed: (){
                cancelEvent(Orgdata[index]['id'], widget.username);
              }, icon: Icon(Icons.delete)), // Optional leading icon
              title: Text(Orgdata[index]['eventname']), // The main text of the list item
              subtitle: Text('Location:${Orgdata[index]['Location']}\nPrice:${Orgdata[index]['Price']}\nTime:${Orgdata[index]['Time']}'), // Optional subtitle
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