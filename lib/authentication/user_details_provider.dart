import 'package:app_name/authentication/cloud_firestore_methods.dart';
import 'package:app_name/authentication/user_details_model.dart';
import 'package:flutter/material.dart';

class UserDetailsProvider with ChangeNotifier {
  UserDetailsModel userDetails;

  UserDetailsProvider()
      : userDetails = UserDetailsModel(name: "Loading", dob: "Loading", language: "Loading", avatar: "Loading", score: 0, tag: "Loading");

  Future getData() async {
    userDetails = await CloudFirestoreClass().getNameAndAddress();
    notifyListeners();
  }
}