import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moderndrycleanersadmin/utils/util.dart';

import '../themeConstants.dart';

const Color kActiveTab = kPrimaryAppColor;
const Color kInActiveTab = Color(0xFF9CD9FA);

class NewItem extends StatefulWidget {
  const NewItem({Key? key}) : super(key: key);

  @override
  State<NewItem> createState() => _OrdersState();
}

class _OrdersState extends State<NewItem> {
  String itemTitle = '';
  int itemPrice = 0;
  String iconPath = 'images/laundry.png'; // Default icon path
  String category = 'pressing';
  var categories = ['pressing', 'washing', 'alteration'];
  var collectionName = 'pressing';
  final FocusNode itemTitleFocusNode = FocusNode();
  final FocusNode itemPriceFocusNode = FocusNode();

  bool isLoading = false; // Loading indicator

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    itemTitleFocusNode.dispose();
    itemPriceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(),
                    ),
                    value: category,
                    items: categories.map((val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        category = val!;
                        switch (val) {
                          case 'pressing':
                            collectionName = 'pressing';
                            break;
                          case 'washing':
                            collectionName = 'press_and_clean_items';
                            break;
                          case 'alteration':
                            collectionName = 'alteration';
                            break;
                        }
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    focusNode: itemTitleFocusNode,
                    onFieldSubmitted: (value) {
                      Utils.fieldFocusChange(
                          context, itemTitleFocusNode, itemPriceFocusNode);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter Item Title',
                      border: OutlineInputBorder(),
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
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    focusNode: itemPriceFocusNode,
                    onFieldSubmitted: (value) {},
                    decoration: const InputDecoration(
                      labelText: 'Enter Item Price (AED)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter item price';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      itemPrice = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text('Selected Icon: '),
                      Image.asset(
                        iconPath,
                        height: 50,
                        width: 50,
                      ),
                      GestureDetector(
                        onTap: () async {
                          String? newPath = await IconsDialog();
                          if (newPath != null) {
                            setState(() {
                              iconPath = newPath;
                            });
                          }
                        },
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryAppColor,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      minimumSize: const Size.fromHeight(50),
                      textStyle: const TextStyle(fontSize: 20),
                      padding: const EdgeInsets.all(10),
                      elevation: 5,
                      shadowColor: Colors.black,
                      side: const BorderSide(width: 1, color: Colors.lightBlue),
                      alignment: Alignment.center,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      animationDuration: const Duration(milliseconds: 500),
                    ),
                    onPressed: isLoading ? null : () => addItem(),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Add"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> IconsDialog() async {
    return await showDialog(
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
                        child: Image.asset(
                          'images/shirt.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/pants.png');
                        },
                        child: Image.asset(
                          'images/pants.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/jacket.png');
                        },
                        child: Image.asset(
                          'images/jacket.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/tie.png');
                        },
                        child: Image.asset(
                          'images/tie.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/dishdasha.jpeg');
                        },
                        child: Image.asset(
                          'images/dishdasha.jpeg',
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
                        child: Image.asset(
                          'images/sweater.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/dress.png');
                        },
                        child: Image.asset(
                          'images/dress.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/suit.png');
                        },
                        child: Image.asset(
                          'images/suit.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/skirt.png');
                        },
                        child: Image.asset(
                          'images/skirt.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/blouse.png');
                        },
                        child: Image.asset(
                          'images/blouse.png',
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
                        child: Image.asset(
                          'images/curtains.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/bedding.png');
                        },
                        child: Image.asset(
                          'images/bedding.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/laundry.png');
                        },
                        child: Image.asset(
                          'images/laundry.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/carpet.png');
                        },
                        child: Image.asset(
                          'images/carpet.png',
                          height: 50,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context, 'images/dressnormal.jpeg');
                        },
                        child: Image.asset(
                          'images/dressnormal.jpeg',
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
                  )
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
            )
          ],
        ),
      ),
    );
  }

  void addItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection(collectionName).add({
          'name': itemTitle,
          'price': itemPrice,
          'icon': iconPath,
        });

        setState(() {
          isLoading = false;
        });

        // ignore: use_build_context_synchronously
        Utils.flushBarSuccessMessage("New Item Added Successfully", context);

        // Reset form fields after successful addition
        _formKey.currentState!.reset();
        itemTitle = '';
        itemPrice = 0;
        iconPath = 'images/laundry.png'; // Reset icon path
        category = 'pressing';
        collectionName = 'pressing';
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Utils.flushBarErrorMessage("Failed to add item: $e", context);
      }
    }
  }
}
