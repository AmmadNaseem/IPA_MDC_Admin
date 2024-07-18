// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:moderndrycleanersadmin/backgroundpainter.dart';
import 'package:moderndrycleanersadmin/utils/util.dart';
import '../MainScreen.dart';
import '../themeConstants.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  Widget body = const LoginUser();

  Color clr = const Color(0xff000000);
  int flag = 0;
  String _header = 'Sign In';
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _auth.setLanguageCode('en');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: CustomPaint(
              painter: BackgroundPainter(animation: _controller.view),
            ),
          ),
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _header,
                        style: const TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ),
              // main FORM widget
              Expanded(child: body),
            ],
          ),
        ],
      ),
    );
  }
}

class LoginUser extends StatefulWidget {
  const LoginUser({Key? key}) : super(key: key);

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool _isInAsyncCall = false;
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  Future<int> doesEmailAlreadyExist(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('admin')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.length;
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isInAsyncCall,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              focusNode: emailFocusNode,
              onSubmitted: (value) {
                Utils.fieldFocusChange(
                    context, emailFocusNode, passwordFocusNode);
              },
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.black,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.black)),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: TextField(
              focusNode: passwordFocusNode,
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              obscureText: true,
              decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.black,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.black)),
            ),
          ),
          Container(
              height: 50,
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryAppColor, // Background color
                ),
                child: const Text('Login'),
                onPressed: () async {
                  if (email.isEmpty) {
                    Utils.flushBarErrorMessage('Please enter email', context);
                    return;
                  }
                  if (password.isEmpty) {
                    Utils.flushBarErrorMessage(
                        'Please enter password', context);
                    return;
                  }
                  setState(() {
                    _isInAsyncCall = true;
                  });
                  try {
                    final loginUser = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);

                    if (loginUser != null) {
                      String email = loginUser.user!.email.toString();

                      if (await doesEmailAlreadyExist(email) == 1) {
                        await FirebaseMessaging.instance
                            .getToken()
                            .then((newToken) {
                          var myToken = newToken.toString();
                          FirebaseFirestore.instance
                              .collection('admin')
                              .doc(email)
                              .update({'token': myToken});
                        });
                        setState(() {
                          _isInAsyncCall = false;
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainScreen()));
                      } else {
                        setState(() {
                          _isInAsyncCall = false;
                        });
                        Utils.flushBarErrorMessage(
                            "You don't have access to admin account", context);

                        FirebaseAuth.instance.signOut();
                      }
                    }
                  } on FirebaseAuthException catch (e) {
                    setState(() {
                      _isInAsyncCall = false;
                    });
                    switch (e.code) {
                      case "wrong-password":
                        Utils.flushBarErrorMessage(
                            "Invalid email or password", context);

                        break;
                      case "invalid-email":
                        Utils.flushBarErrorMessage(
                            "Enter a valid email", context);

                        break;
                      default:
                        Utils.flushBarErrorMessage(
                            e.message ?? "An error occurred", context);
                        break;
                    }
                  }
                },
              )),
        ],
      ),
    );
  }
}
