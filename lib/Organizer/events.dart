import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Events extends StatefulWidget {
  final VoidCallback onUpdate;
  final String org;
  final String eventname;
  final String date;
  final String time;
  final String location;
  final String desc;
  final String cat;
  final String price;
  final int id;
  final int ticket;
  const Events({super.key, required this.org,required this.eventname,required this.date,required this.time,required this.location,required this.desc,required this.cat,required this.price,required this.id,required this.ticket,required this.onUpdate});
  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {  
   List users=[];
  late TextEditingController orgController;
  late TextEditingController eventnameController;
  late TextEditingController location;
  late TextEditingController price;
  late TextEditingController description;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController category;
  late TextEditingController ticket;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current data
    orgController = TextEditingController(text: widget.org);
    eventnameController = TextEditingController(text: widget.eventname);
    dateController = TextEditingController(text: widget.date.substring(0, 10)); // Trim the date to YYYY-MM-DD
    timeController = TextEditingController(text: widget.time);
    location= TextEditingController(text:widget.location);
    description= TextEditingController(text:widget.desc);
    price= TextEditingController(text:widget.price);
    category= TextEditingController(text:widget.cat);
    ticket=TextEditingController(text:widget.ticket.toString());
  }

Future<void> deletedata() async
{
final url = Uri.parse('http://localhost:3000/delete'); // Your server URL here
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
         'id': widget.id,
      }),
    );
}

Future<void> editdata() async
{
final url = Uri.parse('http://localhost:3000/update'); // Your server URL here
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'eventname': eventnameController.text,
        'Location': location.text,
         'Price': price.text,
        'Description': description.text,
         'Category': category.text,
         'Time': timeController.text,
         'Date': dateController.text,
         'Organiser': orgController.text,
         'id': widget.id,
         'ticket':int.parse(ticket.text),

      }),
    );
}

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    orgController.dispose();
    eventnameController.dispose();
    dateController.dispose();
    timeController.dispose();
    location.dispose();
    description.dispose();
    price.dispose();
    category.dispose();
    super.dispose();
  }
  
  // Method to show the dialog
  void editEvent(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Event'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Event Name
                  TextField(
                    controller: eventnameController,
                    decoration: const InputDecoration(labelText: 'Event Name'),
                  ),
                  TextField(
                    controller: location,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  TextField(
                    controller: price,
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                  TextField(
                    controller: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  // Date
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(widget.date),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dateController.text =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                  // Time
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: int.parse(widget.time.split(':')[0]),
                          minute: int.parse(widget.time.split(':')[1]),
                        ),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          timeController.text =
                              "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),   // Organization Name
                  TextField(
                    controller: orgController,
                    decoration: const InputDecoration(labelText: 'Organizer Name'),
                  ),
                    TextField(
                    controller: ticket,
                    decoration: const InputDecoration(labelText: 'Tickets'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: const Text('Cancel'),
            ),
             TextButton(
              onPressed: () {
                deletedata();
                setState(() {
                widget.onUpdate();
                widget.onUpdate();
                });
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                  editdata();
                setState(() {
                widget.onUpdate();
                widget.onUpdate();
                });
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:200,
      child: Card(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
          Text(widget.org,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),),
          Text(widget.eventname,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),),
          Text(widget.date.substring(0,10)),
          Text(widget.time),
          Spacer(),
          Stack(
            children: [
               Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 20,
              child: ElevatedButton(onPressed: (){
                editEvent(context);
                
              }, child:Icon(Icons.edit))),
          ),
            ],
          )
        ],)
      ),
    );
  }
}