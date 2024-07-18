// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moderndrycleanersadmin/themeConstants.dart';
import 'package:moderndrycleanersadmin/utils/util.dart';

enum SelectedTab { pressing, washing, alteration }

const Color kActiveTab = kPrimaryAppColor;
const Color kInActiveTab = Color(0xFF9CD9FA);

class Items extends StatefulWidget {
  const Items({Key? key}) : super(key: key);

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  SelectedTab tabSelected = SelectedTab.washing;
  int tabNumber = 0;
  final db = FirebaseFirestore.instance;
  late String itemTitle;
  int itemPrice = 0;
  String iconPath = 'images/laundry.png';
  String showIcon = 'images/laundry.png';
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                _changeTab(SelectedTab.washing, 0);
              },
              child: Tab(
                tabText: "Pressing",
                cardColor: tabSelected == SelectedTab.washing
                    ? kActiveTab
                    : kInActiveTab,
              ),
            ),
            GestureDetector(
              onTap: () {
                _changeTab(SelectedTab.pressing, 1);
              },
              child: Tab(
                tabText: "Washing",
                cardColor: tabSelected == SelectedTab.pressing
                    ? kActiveTab
                    : kInActiveTab,
              ),
            ),
            GestureDetector(
              onTap: () {
                _changeTab(SelectedTab.alteration, 2);
              },
              child: Tab(
                tabText: "Alteration",
                cardColor: tabSelected == SelectedTab.alteration
                    ? kActiveTab
                    : kInActiveTab,
              ),
            )
          ],
        ),
        Expanded(
          child: SizedBox(
            height: double.infinity,
            child: StreamBuilder<QuerySnapshot>(
              stream: ItemsManagement()
                  .getItems(tabNumber)
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No items found.'),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Image(
                                image: AssetImage(doc['icon']),
                                height: 30,
                                width: 30,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(doc['name'].toString()),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text("${doc['price']} AED"),
                            ),
                            GestureDetector(
                              onTap: () => _confirmDelete(context, doc.id),
                              child: const Icon(Icons.delete),
                            ),
                            GestureDetector(
                              onTap: () => _showUpdateDialog(context, doc),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String itemId) async {
    showDialog(
      context: context,
      builder: (_) => CustomDialogueBox(
        boxTitle: 'Delete this item?',
        providedColumn: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kActiveTab,
              ),
              onPressed: () async {
                await ItemsManagement()
                    .getItems(tabNumber)
                    .doc(itemId)
                    .delete();
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text("Confirm"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateDialog(
      BuildContext context, QueryDocumentSnapshot doc) async {
    itemTitle = doc['name'];
    itemPrice = doc['price'];
    iconPath = doc['icon'];

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CustomDialogueBox(
              boxTitle: "Update Item",
              providedColumn: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextFormField(
                      initialValue: itemTitle,
                      decoration: const InputDecoration(
                        labelText: 'Enter Item Title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter item title';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        itemTitle = value;
                      },
                    ),
                    TextFormField(
                      initialValue: itemPrice.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Enter Item Price (AED)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter item price';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value != null && value.isNotEmpty) {
                          try {
                            itemPrice = int.parse(value);
                          } catch (e) {
                            itemPrice = 0;
                          }
                        } else {
                          itemPrice = 0;
                        }
                      },

                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Text('Selected Icon: '),
                          Image.asset(
                            iconPath,
                            height: 30,
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        String? selectedIconPath = await IconsDialog();
                        if (selectedIconPath != null) {
                          iconPath = selectedIconPath;
                          setState(
                              () {}); // Refresh dialog to show selected icon
                        }
                      },
                      child: const Text('Change Icon'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kActiveTab,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _updateItem(doc.id);
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              }
                            },
                            child: const Text("Update"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  Future<String?> IconsDialog() => showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, 'images/shirt.png');
                          },
                          child: const Image(
                            image: AssetImage('images/shirt.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, 'images/pants.png');
                          },
                          child: const Image(
                            image: AssetImage('images/pants.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, 'images/jacket.png');
                          },
                          child: const Image(
                            image: AssetImage('images/jacket.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, 'images/sweater.png');
                          },
                          child: const Image(
                            image: AssetImage('images/sweater.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, 'images/dress.png');
                          },
                          child: const Image(
                            image: AssetImage('images/dress.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, 'images/suit.png');
                          },
                          child: const Image(
                            image: AssetImage('images/suit.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, 'images/curtains.png');
                          },
                          child: const Image(
                            image: AssetImage('images/curtains.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, 'images/bedding.png');
                          },
                          child: const Image(
                            image: AssetImage('images/bedding.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context, 'images/laundry.png');
                          },
                          child: const Image(
                            image: AssetImage('images/laundry.png'),
                            height: 50,
                            width: 50,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: const Text('Close'),
                    ),
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
        ),
      );

  void _changeTab(SelectedTab newTab, int tabNumber) {
    setState(() {
      tabSelected = newTab;
      this.tabNumber = tabNumber;
    });
  }

  void _updateItem(String itemId) async {
    setState(() {
      isLoading = true;
    });

    try {
      await ItemsManagement().getItems(tabNumber).doc(itemId).update({
        'name': itemTitle,
        'price': itemPrice,
        'icon': iconPath,
      });

      Utils.flushBarSuccessMessage("Item Updated Successfully", context);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      Utils.flushBarErrorMessage("Failed to update item: $e", context);
      setState(() {
        isLoading = false;
      });
    }
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
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
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

class ItemsManagement {
  final db = FirebaseFirestore.instance;

  CollectionReference getItems(int tabNumber) {
    if (tabNumber == 0) {
      return db.collection('pressing');
    } else if (tabNumber == 1) {
      return db.collection('press_and_clean_items');
    } else {
      return db.collection('alteration');
    }
  }
}
