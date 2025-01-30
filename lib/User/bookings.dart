import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class BookinPage extends StatefulWidget {
  final String username;
  const BookinPage({super.key,required this.username});

  @override
  State<BookinPage> createState() => _BookinPageState();
}

class _BookinPageState extends State<BookinPage> {
  List Bookings=[];
  late WebSocketChannel channel;


   @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));
    booking();
    channel.stream.listen((data) {
      var response = json.decode(data);
      if (response['action'] == 'cancelevent' || response['action']=='cancel' || response['action']=='canceluser' || response['action']=='cancelorg') {
        setState(() {
          booking();
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

  Future<void> booking() async {
    String username=widget.username;
    final res = await http.get(Uri.parse('http://localhost:3000/bookings?username=$username'));
    if (res.statusCode == 200) {
      setState(() {
        Bookings = json.decode(res.body);
      });
    } else {
      throw Exception('Failed to fetch\n');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booked Events',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),),
      ),
      body:  
      Column(
        children: [
          const SizedBox(height: 50,),
          Bookings.isEmpty? 
               Align(alignment: Alignment.center,child: Text('No Booking',
               style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
               ),))
            : Expanded(
              child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: Bookings.length,
                    itemBuilder: (context,index)
                    {
                      return Container(
                       margin: EdgeInsets.all(20).copyWith(bottom: 0,right: 400,left: 400),
                       padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black,
                          ),
                          color: Colors.white38,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Align(alignment: Alignment.topLeft,child: Text("Event Name:${Bookings[index]['eventname']}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),)),
                            const SizedBox(height: 10,),
                            Align(alignment: Alignment.topLeft,child: Text("Location:${Bookings[index]['Location']}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),)),
                            const SizedBox(height: 10,),
                            Align(alignment: Alignment.topLeft, child: Text("Organiser:${Bookings[index]['Organiser']}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),)),
                             const SizedBox(height: 15,),
                              Align(alignment: Alignment.topLeft, child: Text("Book Id:${Bookings[index]['bid']}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),)),
                             const SizedBox(height: 15,),
                            Align(alignment: Alignment.topLeft, child: Text("Status:Booked",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),)),
                            const SizedBox(height: 15,),
                            Align(alignment: Alignment.topLeft, child: Text("Quantity:${Bookings[index]['quantity']}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),)),
                            const SizedBox(height: 15,),
                            IconButton(onPressed: ()
                            {
                              cancelTicket(Bookings[index]['eventid'],Bookings[index]['user'],Bookings[index]['bid']);
                            }, icon: Icon(Icons.delete,color: Colors.red,))
                          ],
                        ),
                      );
                    }
                    ),
            ) 
        ],
      )
    );
      
  }
}