import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Pages/orderdetails.dart';
import '../themeConstants.dart';

enum SelectedTab { active, past }

const Color kActiveTab = kPrimaryAppColor;
const Color kInActiveTab = Color(0xFF9CD9FA);

class Orders extends StatefulWidget {
  final query;
  final title;
  const Orders({super.key, required this.query, this.title});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  SelectedTab tabSelected = SelectedTab.active;
  int tabNumber = 0;
  String email = 'HI';
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  //
  // void getSharedPreferences() async{
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     email = prefs.getString('LoggedinEmail')!;
  //     print(email);
  //   });
  // }
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
        setState(() {
          email = loggedInUser.email.toString();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: kPrimaryAppColor,
      ),
      body: Container(
        color: Colors.transparent,
        child: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('orderStatus', whereIn: widget.query)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: snapshot.data!.docs.map((doc) {
                          DateTime orderTime =
                              DateTime.fromMillisecondsSinceEpoch(
                                  doc['orderTime'].seconds * 1000);
                          String formattedDate =
                              DateFormat('yyyy-MM-dd – kk:mm')
                                  .format(orderTime);
                          print("============= Testing =========");
                          print(doc['orderNumber'].toString());
                          print(doc['orderTime']);
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: () {
                                  if (kDebugMode) {
                                    print("MYID:--" + doc.id.toString());
                                  }

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
                                          "${doc['orderType']} Order",
                                          style: const TextStyle(
                                              color: Colors.orange,
                                              fontStyle: FontStyle.italic),
                                        )),
                                        Text("Status: ${doc['orderStatus']}"),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                                  'Order # ${doc['orderNumber']}')),
                                          Text(
                                            formattedDate,
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
            ],
          ),
        ),
      ),
    );
  }
}

class Tab extends StatelessWidget {
  const Tab({super.key, required this.tabText, required this.cardColor});
  final String tabText;
  final Color cardColor;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          margin: const EdgeInsets.all(10),
          child: Text(
            tabText,
            style: const TextStyle(),
          ),
        ),
      ),
    );
  }
}
