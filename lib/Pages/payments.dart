import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moderndrycleanersadmin/themeConstants.dart';

import 'orderdetails.dart';

class Payments extends StatefulWidget {
  const Payments({Key? key}) : super(key: key);

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  int completedOrders = 0;
  int pendingOrders = 0;

  @override
  void initState() {
    super.initState();
    getOrderNumbers();
  }

  void getOrderNumbers() async {
    await FirebaseFirestore.instance
        .collection("orders")
        .where('orderStatus', isEqualTo: 'Completed')
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        completedOrders = querySnapshot.docs.length;
      });
    });

    await FirebaseFirestore.instance
        .collection("orders")
        .where('orderStatus', whereIn: ['Pending', 'Accepted'])
        .get()
        .then((QuerySnapshot querySnapshot) {
          setState(() {
            pendingOrders = querySnapshot.docs.length;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: kPrimaryAppColor,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Card(
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: [
                      const Text("Pending"),
                      Text(pendingOrders.toString()),
                    ],
                  ),
                ),
              ),
              Card(
                child: Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: [
                      const Text("Completed"),
                      Text(completedOrders.toString()),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SizedBox(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .orderBy('orderNumber')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.docs.map((doc) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrderDetails(
                                          doc: doc, id: doc.id.toString())),
                                );
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        'order #${doc['orderNumber']}',
                                        style: const TextStyle(
                                            color: Colors.orange,
                                            fontStyle: FontStyle.italic),
                                      )),
                                      Text("Total bill: ${doc['totalbill']}"),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                            child: Text('Payment type: ')),
                                        Text(
                                          (doc['payment_method']).toString(),
                                          style: const TextStyle(
                                              color: Colors.blueGrey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
