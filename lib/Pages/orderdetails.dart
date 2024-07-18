// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moderndrycleanersadmin/User/userDetails.dart';
import 'package:http/http.dart' as http;
import 'package:moderndrycleanersadmin/utils/util.dart';
import '../themeConstants.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key, required this.doc, this.id});
  final doc;
  final id;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late String name = "";
  late String phone = "";
  late String address = "";
  late String email = "";
  String paymentStatus = 'Pending';
  var updatedStatus = "";

  bool isUpdatingStatusLoading = false;

  final statusesUpdate = [
    'Pending',
    'Accepted',
    'Ready to Pick up',
    'Processing',
    'Ready to Deliver',
    'Completed'
  ];

  getProfile() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        final profileSnapchot = await _firestore
            .collection('Users')
            .where('email', isEqualTo: widget.doc['orderedBy'])
            .get()
            .then((QuerySnapshot querySnapshot) {
          for (var doc in querySnapshot.docs) {
            name = doc['name'];
            phone = doc['phone'];
            address = doc['address'];
            email = doc['email'];
          }
        });
        setState(() {
          profileSnapchot;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getProfile();
    updatedStatus = widget.doc['orderStatus'];
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        backgroundColor: kPrimaryAppColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      "Status : ",
                      style: TextStyle(color: kPrimaryAppColor, fontSize: 15),
                    ),
                    DropdownButton(
                      items: statusesUpdate
                          .map((String item) => DropdownMenuItem<String>(
                              value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          updatedStatus = value!;
                          if (widget.doc['payment_method'] ==
                              'Cash on Delivery') {
                            paymentStatus =
                                value == 'Completed' ? 'Paid' : 'Pending';
                          } else {
                            paymentStatus = 'Paid';
                          }
                        });
                        showDialog(
                            context: context,
                            builder: (_) => CustomDialogueBox(
                                  providedColumn: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          showLoadingDialog(context);
                                          try {
                                            await FirebaseFirestore.instance
                                                .collection('orders')
                                                .doc(widget.id)
                                                .update({
                                              'orderStatus': updatedStatus,
                                              'paymentStatus': paymentStatus
                                            });
                                            var targetToken;
                                            var to = widget.doc['orderedBy'];
                                            var collection = FirebaseFirestore
                                                .instance
                                                .collection('Users');
                                            var docSnapshot =
                                                await collection.doc(to).get();
                                            if (docSnapshot.exists) {
                                              Map<String, dynamic>? data =
                                                  docSnapshot.data();
                                              targetToken = data?['token'];
                                              await http.post(
                                                  Uri.parse(
                                                      "https://www.moderndrycleaners.ae/notification.php"),
                                                  body: {
                                                    'token': targetToken,
                                                    'title':
                                                        "Order ${widget.doc['orderNumber']} has an update",
                                                    'body':
                                                        "Order status now : $updatedStatus"
                                                  });
                                            }
                                            hideLoadingDialog(context);
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                            Utils.flushBarSuccessMessage(
                                                'Status updated successfully',
                                                context);
                                          } catch (e) {
                                            hideLoadingDialog(context);
                                            Utils.flushBarErrorMessage(
                                                'Failed to update status.',
                                                context);
                                          } finally {
                                            setState(() {
                                              isUpdatingStatusLoading = false;
                                            });
                                          }
                                        },
                                        child: const Text("Confirm"),
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              updatedStatus =
                                                  widget.doc['orderStatus'];
                                            });
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          },
                                          child: const Text("Cancel"))
                                    ],
                                  ),
                                  boxTitle: 'Change Order status?',
                                ));
                      },
                      value: updatedStatus,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              buildDetailRow("Ordered By:", widget.doc['orderedBy'], true),
              const SizedBox(height: 10),
              buildDetailRow("Pickup:", widget.doc["pickupTime"], false),
              const SizedBox(height: 10),
              buildDetailRow("Delivery:", widget.doc["dropofftime"], false),
              const Divider(),
              const Text(
                "Pressing",
                style: TextStyle(color: kPrimaryAppColor, fontSize: 15),
              ),
              TextMaker(
                listmap: widget.doc['pressing'],
              ),
              const Divider(),
              const Text(
                "Wash and Press",
                style: TextStyle(color: kPrimaryAppColor, fontSize: 15),
              ),
              TextMaker(listmap: widget.doc["washing"]),
              const Divider(),
              const Text(
                "Alteration",
                style: TextStyle(color: kPrimaryAppColor, fontSize: 15),
              ),
              TextMaker(listmap: widget.doc["alteration"]),
              const Divider(),
              Text("Total Bill: ${widget.doc["totalbill"]}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value, bool isLink) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: kPrimaryAppColor, fontSize: 15),
          ),
        ),
        Expanded(
          flex: 3,
          child: isLink
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Profile(useremail: widget.doc['orderedBy'])),
                    );
                  },
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: kPrimaryAppColor,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(fontSize: 15),
                ),
        ),
      ],
    );
  }
}

class TextMaker extends StatelessWidget {
  TextMaker({required this.listmap});
  final listmap;
  String mytext = "";

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < listmap.length; i++) {
      if (listmap == {}) {
        mytext = "-";
      }
      if (mytext == "") {
        mytext = listmap["$i"][1];
      } else {
        mytext = "$mytext, ${listmap["$i"][1]}";
      }
    }
    return Text(mytext);
  }
}

class CustomDialogueBox extends StatelessWidget {
  const CustomDialogueBox(
      {super.key, required this.providedColumn, required this.boxTitle});
  final Widget providedColumn;
  final String boxTitle;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: Colors.white),
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  boxTitle,
                  style: const TextStyle(fontSize: 20, color: kPrimaryAppColor),
                ),
                providedColumn,
              ],
            ),
          ),
          Positioned(
            top: -100,
            child: Image.asset(
              'images/mdclogo.png',
              height: 150,
              width: 150,
            ),
          ),
        ],
      ),
    );
  }
}
