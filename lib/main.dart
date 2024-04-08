import 'package:app_name/authentication/user_details_provider.dart';
import 'package:app_name/screens/home.dart';
import 'package:app_name/screens/landing.dart';
import 'package:app_name/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Obtain a list of the available cameras on the device.
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(

      options: DefaultFirebaseOptions.currentPlatform,

    );
  runApp(const project1());
}

// ignore: camel_case_types
class project1 extends StatelessWidget {
  const project1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => UserDetailsProvider())],
    child: MaterialApp(
      title: "Rights Whiz",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Color.fromARGB(255, 230, 124, 129),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> user) {
          if (user.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            );
          } else if (user.hasData) {
            return const home();
          } else {
            return const landing();
          }
        },
      ),
    ),
    );
  }
}
