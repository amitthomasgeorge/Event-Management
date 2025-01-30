import 'package:flutter/material.dart';

class EventDetail extends StatelessWidget {

  const EventDetail({super.key});

  @override
  Widget build(BuildContext context) {
    double screenwidth= MediaQuery.of(context).size.width;
       double margin;
       if(screenwidth<600)
       {
          margin=double.minPositive;
       }
       else
       {
        margin=400;
       }
    final args= ModalRoute.of(context)?.settings.arguments as Map<String,dynamic>;
        final org=args['Organiser'];
       final eventname=args['eventname'];
        final date=args['Date'];
         final time=args['Time'];
          final location=args['Location'];
          final description=args['Description'];
          final Category=args['Category'];
         final price=args['Price'];
         final id = args['id'];
    return Scaffold(
      appBar: AppBar(
        title: Text(org,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 35,
        ),),
      ),
      body: Padding(
        padding: EdgeInsets.only(top:80),
        child: Column(
          children: [
            const SizedBox(height: 20,),
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(120).copyWith(
                          top: 20,
                          right: margin,
                          left: margin,
                          bottom: 20,
                        ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(203, 195, 227, 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Text(eventname,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),),
                      const SizedBox(height: 30,),
                      Align(alignment: Alignment.topLeft,child: Text('Category:\t\t${Category}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),)),
                      const SizedBox(height: 15,),
                      Align(alignment: Alignment.topLeft,child: Text('Description:\n${description}',
                       style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ))),
                      const SizedBox(height: 15,),
                      Align(alignment: Alignment.topLeft,child:Text('Location:\t\t${location}',
                       style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ))),
                      const SizedBox(height: 15,),
                      Align(alignment: Alignment.topLeft,child:Text('Ticket Price:\t\t${price}',
                       style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ))),
                      const SizedBox(height: 15,),
                      Align(alignment: Alignment.topLeft,child:Text('Date:\t\t${date.substring(0,10)}',
                       style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ))),
                      const SizedBox(height: 15,),
                      Align(alignment: Alignment.topLeft,child:Text('Time:\t\t${time}',
                       style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ))),
                      const SizedBox(height: 15,),
                      ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}