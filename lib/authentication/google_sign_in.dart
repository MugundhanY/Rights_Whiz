import 'package:app_name/authentication/cloud_firestore_methods.dart';
import 'package:app_name/authentication/user_details_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

String name = "";

class AuthService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CloudFirestoreClass cloudFirestoreClass = CloudFirestoreClass();

  Future<String> signUpwithGoogle() async {
    String output = "Something went wrong";

    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );


      await firebaseAuth.signInWithCredential(credential);
      output = "success";
    } on FirebaseAuthException catch (e) {
      output = e.message.toString();
    }

    return output;
  }

  Future<String> signOutWithGoogle() async {
    await FirebaseAuth.instance.signOut();
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    return "";
  }
}
