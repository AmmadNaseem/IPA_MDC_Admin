import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moderndrycleanersadmin/OrdersManagement/orders.dart';
import 'package:moderndrycleanersadmin/Pages/payments.dart';
import 'package:moderndrycleanersadmin/login.dart';
import 'package:moderndrycleanersadmin/themeConstants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int completedOrders = 0;
  int pendingOrders = 0;
  int progress = 0;
  int totalOrders = 0;

  @override
  void initState() {
    super.initState();
    getOrderNumbers();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(flex: 1, child: Container()),
                GestureDetector(
                  onTap: () async {
                    final email =
                        await FirebaseAuth.instance.currentUser!.email;
                    FirebaseFirestore.instance
                        .collection('admin')
                        .doc(email.toString())
                        .update({'token': ''});

                    await FirebaseAuth.instance.signOut().then((value) =>
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                            (route) => false));
                  },
                  child: const Text(
                    'LOGOUT',
                    style: TextStyle(
                      color: kPrimaryAppColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Payments()));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: Colors.lightBlue[50],
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: Image(
                            image: AssetImage('images/payment.png'),
                            height: 40,
                            width: 40,
                          )),
                          Expanded(
                              flex: 2,
                              child: Text(
                                'Payments',
                                style: TextStyle(fontSize: 20),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Orders(
                              query: ['Completed'],
                              title: 'Orders Completed')));
                },
                child: DashboardItem(
                  providedTitle: 'Orders Completed',
                  providedCount: completedOrders.toString(),
                  providedGraphic: 'images/completed.gif',
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Orders(
                              query: ['Pending', 'Accepted'],
                              title: 'Orders Pending')));
                },
                child: DashboardItem(
                  providedTitle: 'Orders Pending',
                  providedCount: pendingOrders.toString(),
                  providedGraphic: 'images/pending.gif',
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Orders(
                                title: 'Orders In progress',
                                query: [
                                  'Processing',
                                  'Ready to Pick up',
                                  'Ready to Deliver'
                                ],
                              )));
                },
                child: DashboardItem(
                  providedTitle: 'Orders In Progress',
                  providedCount: progress.toString(),
                  providedGraphic: 'images/progress.gif',
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Orders(
                                title: 'Total Orders',
                                query: [
                                  'Pending',
                                  'Accepted',
                                  'Processing',
                                  'Ready to Pick up',
                                  'Ready to Deliver',
                                  'Completed'
                                ],
                              )));
                },
                child: DashboardItem(
                  providedTitle: 'Total Orders',
                  providedCount: totalOrders.toString(),
                  providedGraphic: 'images/totalorders.gif',
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Card(
              child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  // Chart title
                  title: ChartTitle(text: 'Orders Overview'),
                  // Enable legend
                  legend: Legend(isVisible: true),
                  // Enable tooltip
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<_SalesData, String>>[
                    LineSeries<_SalesData, String>(
                        dataSource: [
                          _SalesData('Completed', completedOrders),
                          _SalesData('Pending', pendingOrders),
                          _SalesData('In Progress', progress),
                          _SalesData('Total', totalOrders),
                        ],
                        xValueMapper: (_SalesData sales, _) => sales.year,
                        yValueMapper: (_SalesData sales, _) => sales.sales,
                        name: 'Orders',
                        // Enable data label
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true))
                  ]),
            ),
          ),
        ],
      ),
    );
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

    await FirebaseFirestore.instance
        .collection("orders")
        .where('orderStatus',
            whereIn: ['Processing', 'Ready to Pick up', 'Ready to Deliver'])
        .get()
        .then((QuerySnapshot querySnapshot) {
          setState(() {
            progress = querySnapshot.docs.length;
          });
        });

    await FirebaseFirestore.instance
        .collection("orders")
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        totalOrders = querySnapshot.docs.length;
      });
    });
  }
}

class DashboardItem extends StatelessWidget {
  const DashboardItem(
      {super.key,
      required this.providedTitle,
      required this.providedCount,
      required this.providedGraphic});

  final String providedTitle;
  final String providedCount;
  final String providedGraphic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        elevation: 5,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                topRight: Radius.circular(10)),
            side: BorderSide(width: 1, color: Colors.lightBlue)),
        child: SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 30,
          child: Column(
            children: [
              Image(
                image: AssetImage(providedGraphic),
                height: 80,
                width: 80,
              ),
              Text(
                providedTitle,
                style: const TextStyle(fontSize: 16, color: kPrimaryAppColor),
              ),
              Text(
                "$providedCount + ",
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final int sales;
}
