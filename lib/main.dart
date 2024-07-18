import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moderndrycleanersadmin/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  ,*/

  await Firebase.initializeApp(
/*    options: const FirebaseOptions(
      apiKey: 'AIzaSyCQLj0LHwHkCF1i6zL5Px0b-kSkUv0CZRM',
      appId: '1:819041530713:android:54e53c195f517d43371248',
      messagingSenderId: '819041530713',
      projectId: 'modern-dry-cleaners',
    ),*/
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBlxFJkzf7cRaP-MPyFD3Ek2Ial9Mktj_8',
      appId: '1:819041530713:android:54e53c195f517d43371248',
      messagingSenderId: '819041530713',
      projectId: 'modern-dry-cleaners',
      storageBucket: 'modern-dry-cleaners.appspot.com',
    ),
  );
  FirebaseAuth.instance.setLanguageCode('en');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: ColorScheme.fromSeed(seedColor: Colors.white).primary),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      home: const Splash(),
    );
  }
}
