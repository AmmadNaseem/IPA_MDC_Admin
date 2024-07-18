import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../themeConstants.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key, this.useremail}) : super(key: key);
  final useremail;
  @override
  State<Profile> createState() => _ProfileState();
}


class _ProfileState extends State<Profile> {
  final _firestore= FirebaseFirestore.instance;

  late String name ="";
  late String phone ="";
  late String address="";
  late String email="";
  bool _isInAsyncCall = false;
  getProfile() async{
    try{
      setState(() {
        _isInAsyncCall = true;

      });

        final profileSnapchot = await _firestore.collection('Users').where('email',isEqualTo:widget.useremail ).get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {

            name = doc['name'];
            phone = doc['phone'];
            address = doc['address'];
            email = doc['email'];
          });
        });
        setState(() {
          _isInAsyncCall = false;
          profileSnapchot;
        });



    }
    catch(e){
      print(e);
    }


  }
  @override
  void initState() {
    super.initState();
    getProfile();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile",
          style: TextStyle(color: kPrimaryAppColor,
            fontSize: 15,
          ),),
        iconTheme: IconThemeData(
          color: kPrimaryAppColor, //change your color here
        ),
        backgroundColor: Colors.white,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isInAsyncCall,
        child: Container(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              child: Center(child: Column(
                children: [
                  SizedBox(height: 20,),
                  Image(image: AssetImage('images/user.png'),height: 100, width: 100,),
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(),
                        Text("Name: ",style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name, style: TextStyle(fontSize: 17),),

                          ],
                        ),
                        Divider(),
                        Text("Email: ",style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                        Text(email,style: TextStyle(fontSize: 17)),
                        Divider(),

                        Text("Phone: ",style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text(phone.toString(),style: TextStyle(fontSize: 17)),

                        Divider(),
                        Text("Address: ",style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Row(

                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width:200,
                              child: Text(address,style: TextStyle(fontSize: 17),
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,),
                            ),

                          ],
                        ),
                        Divider(),
                      ],
                    ),
                  )



                ],
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
