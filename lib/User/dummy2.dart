import 'dart:convert';
import 'package:eventmanagement/Login.dart';
import 'package:eventmanagement/User/bookings.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
class DashboardUser extends StatefulWidget {
   final String username;
  const DashboardUser({super.key,required this.username});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
   String? selectedLocation;
 String? selectedCategory;
 String Orgbooked='';
   List<String> Location= [];
  List<String> Category= [];
  final TextEditingController field1Controller = TextEditingController();
  List users = [];
 int finalquantity=1;
  late WebSocketChannel channel;
  Razorpay _razorpay = Razorpay();
  late int ids;
  @override
  void initState() {
    super.initState();
    fetchLocation();
    fetchCategory();
     if(selectedLocation==null && selectedCategory==null)
    fetch();
    else 
    fetchdrop(selectedLocation,selectedCategory);
    
    channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    channel.stream.listen((data) {
      var response = json.decode(data);
      if (response['action'] == 'update' || response['action'] == 'cancelevent') {
        setState(() {
             if(selectedLocation==null && selectedCategory==null)
              fetch();
              else 
              fetchdrop(selectedLocation,selectedCategory);
        });
      }
       if (response['action'] == 'cancel' || response['action'] == 'cancelevent') {
        setState(() {
             fetch();
        });
      }
    });
  }


 Color iconColor = Colors.white; // Initial color of the icon

  void changeColor() {

    setState(() {
      iconColor = iconColor == Colors.white ? Colors.red : Colors.white; // Toggle color
    });
  }



Future<void> processPayment(int id, double price,String quantity,String Org) async {
  ids = id;
  Orgbooked=Org;
  int quant=int.parse(quantity);
  double amount=(price *quant);
  finalquantity=quant;
  print(amount);
  try {

    // Step 1: Get order details from the backend
    final response = await http.post(
      Uri.parse('http://localhost:3000/create-order'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'amount': amount}),
    );

    if (response.statusCode == 200) {
      var orderData = json.decode(response.body);
      
      // Step 2: Call Razorpay payment gateway with order ID
      var options = {
        'key': 'rzp_test_7gBCnoEsPrcvyr', // Your Razorpay Key
        'amount': (price * 100 * quant).toString(),
        'order_id': orderData['id'],
        'name': 'Event Payment',
        'description': 'Payment for Event Ticket',
        'prefill': {
          'contact': '1234567890',
          'email': 'user@example.com',
        },
        'external': {
          'wallets': ['paypal']
        }
      };

      _razorpay.open(options);
    } else {
      throw Exception('Failed to create order');
    }
  } catch (e) {
    print('Error: $e');
  }
}

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Show success message
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Payment Successful'),
        content: Text('Your ticket has been booked successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );

    // Optionally notify the server about the successful booking
    bookTicket(ids,finalquantity);
    booked(ids,finalquantity,Orgbooked);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Show error message
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Payment Failed'),
        content: Text('Your payment could not be processed. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleExternalWallet() {
    // Handle the case when the user cancels the payment
    print("Payment cancelled");
  }

  // Send a booking request
  void bookTicket(int id,int finalquantity) {
    final message = json.encode({
      'action': 'book',
      'id': id,
      'quantity':finalquantity,
    });
    channel.sink.add(message);
  }

  Future<void> fetch() async {
    final res = await http.get(Uri.parse('http://localhost:3000/fetchuser'));
    if (res.statusCode == 200) {
      setState(() {
        users = json.decode(res.body);
      });
    } else {
      throw Exception('Failed to fetch\n');
    }
  }



Future<void> booked(int eventid,int finalquantity,String Organiser) async
{
final url = Uri.parse('http://localhost:3000/booked'); // Your server URL here
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
      'username': widget.username,
      'wid': eventid,
      'quantity':finalquantity,
      'Organiser': Organiser,
      }),
    );
}

 Future<void> fetchLocation() async {

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/locationadmin'));
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

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/categoryadmin'));
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

Future<void> fetchdrop(String? Location,String ? Category) async {
  String query='';
  if(selectedLocation!=null) query+="Location=$selectedLocation&";
  if(selectedCategory!=null) query+="Category=$selectedCategory&";
  final res= await http.get(Uri.parse('http://localhost:3000/fetchdropadmin?$query'));
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


  @override
  void dispose() {
    super.dispose();
    _razorpay.clear(); // Dispose Razorpay instance when widget is disposed
  }


  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double margin;
    if (screenwidth < 1000) {
      margin = double.minPositive;
    } else {
      margin = 400;
    }
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            tooltip: 'View Orders',
            onPressed: () {
             // Navigate to the second screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookinPage(username: widget.username),
                    ),
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'WishList',
            onPressed: () {
              
            },
          ),
          IconButton(onPressed: (){
            Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                  (Route<dynamic> route)=> false,
                );
          }, icon: const Icon(Icons.logout),
            tooltip: 'Logout',)
        ],
      ),
      body: Column(
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
                      selectedLocation=null;
                      selectedCategory=null;
                    });
                  }, child: Icon(Icons.refresh)),
            ],
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: Text(
              'EXPLORE YOURSELF WITH EVENTS',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              'GRAB YOUR TICKET',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          users.isEmpty
              ? Text('No Events')
              : Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/eventdetail',
                                arguments: {
                                  "Organiser": users[index]['Organiser'],
                                  "eventname": users[index]['eventname'],
                                  "Date": users[index]['Date'],
                                  "Time": users[index]['Time'],
                                  "Location": users[index]['Location'],
                                  "Description": users[index]['Description'],
                                  "Category": users[index]['Category'],
                                  "Price": users[index]['Price'],
                                  "id": users[index]['id'],
                                });
                          },
                          child: Container(
                              height: 250,
                              margin: EdgeInsets.all(16).copyWith(
                                right: margin,
                                left: margin,
                              ),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(203, 195, 227, 1),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    users[index]['Organiser'],
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 15,),
                                  Text('Event Name:${users[index]['eventname']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                  const SizedBox(height: 10,),
                                  Text("Date:${users[index]['Date'].substring(0, 10)}", style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                  const SizedBox(height: 10,),
                                  Text("Time:${users[index]['Time']}", style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                  const SizedBox(height: 10,),
                                  Text("Avaible Tickets:${users[index]['ticket'].toString()}", style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                  const SizedBox(height: 10,),
                                  Padding(
                                    padding: EdgeInsets.all(16)
                                        .copyWith(top: 0, bottom: 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: IconButton(
                                              onPressed: () {
                                              changeColor();
                                              },
                                              icon: Icon(
                                                Icons.favorite,
                                                color: iconColor,
                                              ),
                                            )),
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: GestureDetector(
                                              onTap: () {
                                                  showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: Text('No of Tickets'),
                                                      content:   TextField(
                                                        controller: field1Controller,
                                                        decoration: const InputDecoration(
                                                          labelText: 'Description',
                                                        ),
                                                      ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                             processPayment(
                                                                users[index]['id'],
                                                                double.parse(users[index]['Price']),
                                                                field1Controller.text,
                                                                users[index]['Organiser'],
                                                             );
                                                             setState(() {
                                                                Navigator.of(context).pop();
                                                                field1Controller.clear();
                                                             });
                                                        },
                                                        child: Text('Book'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  'Pay & Book',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  )
                                ],
                              )),
                        );
                      }),
                ),
        ],
      ),
    );
  }
}