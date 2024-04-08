import 'package:app_name/authentication/cloud_firestore_methods.dart';
import 'package:app_name/authentication/user_details_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthenticationMethods {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CloudFirestoreClass cloudFirestoreClass = CloudFirestoreClass();

  Future<String> signUpUser({required String confirmPassword,
    required String email,
    required String password}) async {
    email.trim();
    confirmPassword.trim();
    password.trim();
    String output = "Something went wrong";

    if (confirmPassword != "" && email != "" && password != "") {
      output = "success";
      if (password != confirmPassword) {
        output = "Password do not match";
      } else {
        try {
          await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password);
          output = "success";
        } on FirebaseAuthException catch (e) {
          output = e.message.toString();
        }
      }
    } else {
      output = "Please fill up all the fields.";
    }
    return output;
  }

  Future<String> signInUser(
      {required String email, required String password}) async {
    email.trim();
    password.trim();
    String output = "Something went wrong";
    if (email != "" && password != "") {
      try {
        await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
        output = "success";
      } on FirebaseAuthException catch (e) {
        output = e.message.toString();
      }
    } else {
      output = "Please fill up all the fields.";
    }
    return output;
  }

  Future<String> signUpUserDetails({required String name,
    required String dob,
    required String language,
    required String avatar}) async {
    name.trim();
    dob.trim();
    language.trim();
    avatar.trim();
    String output = "Something went wrong";

    if (name != "" && dob != "" && language != "" && avatar != "") {
      output = "success";
      try {
        UserDetailsModel user = UserDetailsModel(
            name: name, dob: dob, language: language, avatar: avatar, score: 0, tag: "User");
        await cloudFirestoreClass.uploadNameAndAddressToDatabase(user: user);
        output = "success";
      } on FirebaseAuthException catch (e) {
        output = e.message.toString();
      }
    } else {
      output = "Please fill up all the fields.";
    }
    return output;
  }

Future<String> updateUserDetails({required String name,
  required String dob,
  required String language,
  required String avatar}) async {
  name.trim();
  dob.trim();
  language.trim();
  avatar.trim();
  String output = "Something went wrong";

  if (name != "" && dob != "" && language != "" && avatar != "") {
    output = "success";
    try {
      editUserDetailsModel user = editUserDetailsModel(
          name: name, dob: dob, language: language, avatar: avatar);
      await cloudFirestoreClass.updateProfileToDatabase(user: user);
      output = "success";
    } on FirebaseAuthException catch (e) {
      output = e.message.toString();
    }
  } else {
    output = "Please fill up all the fields.";
  }
  return output;
}
}