// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moderndrycleanersadmin/MainScreen.dart';
import 'package:moderndrycleanersadmin/login.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  bool isUser = false;
  late AnimationController animationController;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(seconds: 1), upperBound: 40, vsync: this);
    animationController.forward();
    animationController.addListener(() {
      setState(() {
        animationController.value;
      });
    });

    getCurrentUser();
    _navigateToHome();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        isUser = true;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Hero(
            tag: 'logo',
            child: CircleAvatar(
              radius: animationController.value,
              backgroundColor: Colors.white,
              child: const Image(
                image: AssetImage('images/mdclogo.png'),
              ),
            ),
          ),
          // Text("Modern Dry Cleaners",style: TextStyle(
          //   fontSize: animationController.value-10,
          //   fontWeight: FontWeight.bold,
          //   color: kPrimaryAppColor,
          // ),)
        ]),
      ),
    );
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500), () {});
    if (isUser == true) {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
          transitionDuration: const Duration(seconds: 2),
          pageBuilder: (_, __, ___) => MainScreen()));
    } else {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
          transitionDuration: const Duration(seconds: 2),
          pageBuilder: (_, __, ___) => const Login()));
    }
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
  }
}
