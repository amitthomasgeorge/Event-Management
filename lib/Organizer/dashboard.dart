import 'dart:convert';
import 'package:eventmanagement/Login.dart';
import 'package:eventmanagement/Organizer/events.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Dashboard extends StatefulWidget {
 final String username;
  const Dashboard({super.key,required this.username});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List users=[];
  List<String> Location= [];
  List<String> Category= [];
  final TextEditingController field1Controller = TextEditingController();
  final TextEditingController field2Controller = TextEditingController();
  final TextEditingController field3Controller = TextEditingController();
  final TextEditingController field4Controller = TextEditingController();
  final TextEditingController field5Controller = TextEditingController();
  final TextEditingController field6Controller = TextEditingController();
  final TextEditingController field7Controller = TextEditingController();

String? selectedDate;
String? selectedTime;
 String? selectedLocation;
 String? selectedCategory;

@override
  void initState() {
    super.initState();
    fetchLocation();
    fetchCategory();
    if(selectedLocation==null && selectedCategory==null)
    fetch();
    else 
    fetchdrop(selectedLocation,selectedCategory);
  }

  Future<void> fetchLocation() async {
    String username=widget.username;
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/location?username=$username'));
      if (response.statusCode == 200) {
        // Decode the JSON response and update the list
        setState(() {
          Location = List<String>.from(json.decode(response.body));
          print(Location);
        });
      } else {
        print('Failed to fetch names: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching names: $e');
    }
  }


  Future<void> fetchCategory() async {
    String username=widget.username;
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/category?username=$username'));
      if (response.statusCode == 200) {
        // Decode the JSON response and update the list
        setState(() {
          Category = List<String>.from(json.decode(response.body));
          print(Category);
        });
      } else {
        print('Failed to fetch names: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching names: $e');
    }
  }


 Future<void> filtered() async {
    try {
      final response = await http.post(Uri.parse('http://localhost:3000/fetchdrop'));
      if (response.statusCode == 200) {
        // Decode the JSON response and update the list
        setState(() {
          Location = List<String>.from(json.decode(response.body));
          print(Location);
        });
      } else {
        print('Failed to fetch names: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching names: $e');
    }
  }


Future<void> fetchdrop(String? Location,String ? Category) async {
  String username=widget.username;
  String query='';
  if(selectedLocation!=null) query+="Location=$selectedLocation&";
  if(selectedCategory!=null) query+="Category=$selectedCategory&";
  query+="username=$username&";
  final res= await http.get(Uri.parse('http://localhost:3000/fetch?$query'));
  if(res.statusCode==200)
  {
    setState(() {
      users=json.decode(res.body);
    });
  }
  else
  {
    throw Exception('Failed to fetch\n');
  }
}
Future<void> fetch() async {
  String username=widget.username;
  final res= await http.get(Uri.parse('http://localhost:3000/fetch?username=$username'));
  if(res.statusCode==200)
  {
    setState(() {
      users=json.decode(res.body);
      selectedCategory=null;
      selectedLocation=null;
      fetchLocation();
      fetchCategory();
    });
  }
  else
  {
    throw Exception('Failed to fetch\n');
  }
}

Future<void> submitdata() async
{
final url = Uri.parse('http://localhost:3000/submit'); // Your server URL here
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'eventname': field1Controller.text,
        'Location': field2Controller.text,
         'Price': field5Controller.text,
        'Description': field3Controller.text,
         'Category': field4Controller.text,
         'Time': selectedTime,
         'Date': selectedDate,
         'Organiser': field6Controller.text,
         'ticket': field7Controller.text,
         'username':widget.username,

      }),
    );
}

  // Method to show the dialog
  void addentry(BuildContext context) {
    // Local variable for managing date in the dialog
    String? localSelectedDate;
    String? localSelectedTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Event'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Text field 1
                      TextField(
                        controller: field1Controller,
                        decoration: const InputDecoration(
                          labelText: 'Event Name',
                        ),
                      ),
                      // Text field 2
                      TextField(
                        controller: field2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                        ),
                      ),
                      // Text field 3
                      TextField(
                        controller: field3Controller,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                         // Text field 4
                      TextField(
                        controller: field4Controller,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                      ),
                         // Text field 5
                      TextField(
                        controller: field5Controller,
                        decoration: const InputDecoration(
                          labelText: 'Ticket Price',
                        ),
                      ),
                     TextField(
                        controller: field6Controller,
                        decoration: const InputDecoration(
                          labelText: 'Organization',
                        ),
                      ),
                      const SizedBox(height: 15,),
                       TextField(
                        controller: field7Controller,
                        decoration: const InputDecoration(
                          labelText: 'Ticket',
                        ),
                      ),
                      const SizedBox(height: 15,),
                      InkWell(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                
                          if (pickedDate != null) {
                            setDialogState(() {
                              localSelectedDate =
                                  "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                                  selectedDate=localSelectedDate;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Pick a Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            localSelectedDate ?? 'No Date Selected',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                       const SizedBox(height: 20),
                      // Time picker field
                      InkWell(
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                
                          if (pickedTime != null) {
                            setDialogState(() {
                              localSelectedTime =
                                  "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                                  selectedTime=localSelectedTime;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Pick a Time',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            localSelectedTime ?? 'No Time Selected',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            // Submit button
            TextButton(
              onPressed: () {
                 selectedDate = localSelectedDate;
                  submitdata();
                // Save the selected date to the main state
                setState(() {
                  fetch();
                  fetch();
                  fetchCategory();
                  fetchLocation();
                  selectedCategory=null;
                  selectedLocation=null;
                  field1Controller.clear();
                  field2Controller.clear();
                  field3Controller.clear();
                  field3Controller.clear();
                  field4Controller.clear();
                  field5Controller.clear();
                  field6Controller.clear();
                  field7Controller.clear();
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organization'),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                    DropdownButton<String>(
                    value: selectedLocation,
                    hint: const Text('Select Location'),
                    items: Location
                        .map((location) => DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = value;
                        fetchdrop(selectedLocation,selectedCategory);
                        
                      });
                    },
                  ),
                  DropdownButton<String>(
                    value: selectedCategory,
                    hint: const Text('Select Category'),
                    items: Category
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        fetchdrop(selectedLocation,selectedCategory);
                        
                      });
                    },
                  ),
                  ElevatedButton(onPressed: (){
                    setState(() {
                      fetch();
                    });
                  }, child: Icon(Icons.refresh))
              ],
            ),
            Image.asset('assets/images/org.png',
            height: 300,
            ),
            const SizedBox(height: 20,),
            users.isEmpty? 
              Text('Create Events')
            : 
              SizedBox(
              height: 120,
              child:  ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context,index)
                {
                        final org=users[index]['Organiser'];
                        final eventname=users[index]['eventname'];
                        final date=users[index]['Date'];
                        final time=users[index]['Time'];
                        final location=users[index]['Location'];
                        final description=users[index]['Description'];
                        final Category=users[index]['Category'];
                        final price=users[index]['Price'];
                        final id = users[index]['id'];
                        final ticket = users[index]['ticket'];
                         return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Events(org:org,eventname:eventname,date:date,time:time,location: location,desc: description,cat: Category,price: price,id:id,ticket:ticket,onUpdate: fetch,));
                }),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(onPressed: ()=>{
                addentry(context),
              },
              child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}