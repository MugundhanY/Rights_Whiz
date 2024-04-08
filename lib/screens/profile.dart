import 'package:app_name/authentication/authentication_methods.dart';
import 'package:app_name/authentication/cloud_firestore_methods.dart';
import 'package:app_name/authentication/user_details_model.dart';
import 'package:app_name/authentication/user_details_provider.dart';
import 'package:app_name/constants/utils.dart';
import 'package:app_name/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../widgets/sidebar.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  final String currentPage = 'My Profile';

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String selectedLanguage = 'English';
  String selectedAvatar = '';
  String phoneNumber = "";
  String email = "";
  String selectedDate = "";
  AuthenticationMethods authenticationMethods = AuthenticationMethods();
  List<String> officialLanguages = [
    'Assamese',
    'Bengali',
    'Bodo',
    'Dogri',
    'English',
    'Gujarati',
    'Hindi',
    'Kannada',
    'Kashmiri',
    'Konkani',
    'Maithili',
    'Malayalam',
    'Manipuri',
    'Marathi',
    'Nepali',
    'Odia',
    'Punjabi',
    'Sanskrit',
    'Santali',
    'Sindhi',
    'Tamil',
    'Telugu',
    'Urdu',
  ];

  List<String> avatarList = [
    'assets/av1.png',
    'assets/av2.png',
    'assets/av3.png',
    'assets/av4.png',
  ];

  @override
  void initState() {
    super.initState();
    CloudFirestoreClass().getNameAndAddress();
    _loadUserData();
  }
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      email = user?.email ?? '';
      phoneNumber = user?.phoneNumber ?? '';
      emailController.text = phoneNumber.isNotEmpty ? phoneNumber : email;
    });
  }

  void runOnce(UserDetailsModel userDetails) {
    if (!_hasRun) {
      selectedDate = userDetails.dob;
      selectedAvatar = userDetails.avatar;
      if(userDetails.language != "")selectedLanguage = userDetails.language;
      else selectedLanguage = "English";
      nameController.text = userDetails.name;
      _hasRun = true;
    }
  }

  bool isEditing = false;
  bool _hasRun = false;

  void showImageSourceSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select an Avatar:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20, // Reduced avatar text size
              color: Color(0xFF4303F5),
            ),
          ),
          content: SingleChildScrollView(
            child:  Column (
        children:[
            SizedBox(height: 10), // Reduced spacing
            Wrap(
              alignment: WrapAlignment.center, // Align avatars in the center
              children: avatarList.map((avatar) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAvatar = avatar;
                      if (mounted) Navigator.pop(context);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    width: 80, // Increased avatar size
                    height: 80, // Increased avatar size
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      image: DecorationImage(
                        image: AssetImage(avatar),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            ],
          ),
        ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    Provider.of<UserDetailsProvider>(context).getData();
    UserDetailsModel userDetails =
        Provider.of<UserDetailsProvider>(context).userDetails;
    runOnce(userDetails);
    return Scaffold(
      drawer: AppDrawer(currentPage: currentPage),
      appBar: AppBar(
        title: Text('My Profile'),
          backgroundColor: Color.fromARGB(255, 220, 64, 72)
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFF5E1DA),
      body: Container(
        padding: EdgeInsets.all(20), // Increased outer padding
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch widgets horizontally
              children: [
                SizedBox(height: 20),
            Align(
              alignment: Alignment.topCenter,
            child: Stack(
              alignment: Alignment.topRight, // Position the edit button at the top-right corner
              children: [
                ClipOval(
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        selectedAvatar,
                        width: 150, // Adjust the width and height as needed
                        height: 150, // to control the size of the image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (!isEditing)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue, // Customize the button background color
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.white, // Customize the button icon color
                      onPressed: () {
                        // Handle edit button press
                        showImageSourceSelectionDialog();
                      },
                    ),
                  ),
                ],
            ),
            ),
                SizedBox(height: 20),
                Text(
                  'Name:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Reduced name text size
                    color: Colors.black, // Text color
                  ),
                ),
                SizedBox(height: 10), // Reduced spacing
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Input field background color
                    borderRadius: BorderRadius.circular(10), // Reduced border radius
                  ),
                  child: TextField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      prefixIcon: Icon(
                        Icons.person,
                        color:Colors.black, // Icon color
                      ),
                      border: InputBorder.none, // Removed border
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                    phoneNumber.isNotEmpty ? 'Phone Number:' : 'Email:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Reduced name text size
                    color: Colors.black, // Text color
                  ),
                ),
                SizedBox(height: 10), // Reduced spacing
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Input field background color
                    borderRadius: BorderRadius.circular(10), // Reduced border radius
                  ),
                  child: TextField(
                    enabled: false,
                    controller: emailController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: phoneNumber.isNotEmpty ? 'Phone Number' : 'Email',
                      prefixIcon: Icon(
                        Icons.email_rounded,
                        color: Colors.black, // Icon color
                      ),
                      border: InputBorder.none, // Removed border
                    ),
                    maxLines: 1,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && picked != DateTime.now()) {
                      // Format the picked date as "dd-MM-yy"
                      final formattedDate = DateFormat('dd-MM-yy').format(picked);
                      setState(() {
                        selectedDate = formattedDate; // Update the selected date
                      });
                    }
                    // Do something with the selectedDate
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 230, 124, 129), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Text(
                      'Change Date of Birth',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Selected Date of Birth: $selectedDate',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Language preferences',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Reduced language text size
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10), // Reduced spacing
                DropdownButton<String>(
                  hint: Text(
                    'Select a Language',
                    style: TextStyle(
                      fontSize: 16, // Reduced dropdown hint text size
                      color: Colors.black,
                    ),
                  ),
                  value: selectedLanguage,
                  onChanged: (newValue) {
                    setState(() {
                      selectedLanguage = newValue!;
                    });
                  },
                  items: officialLanguages.map((String language) {
                    return DropdownMenuItem<String>(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10), // Reduced spacing
                Text(
                  'Selected Language: $selectedLanguage',
                  style: TextStyle(
                    fontSize: 16, // Reduced selected language text size
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Add your sign-in logic here
                    setState(() {
                      isLoading = true;
                    });
                    String output = await authenticationMethods.updateUserDetails(
                        name: nameController.text,
                        dob: selectedDate,
                        language: selectedLanguage,
                        avatar: selectedAvatar);
                    setState(() {
                      isLoading = false;
                    });
                    if (output == "success") {
                      // ignore: use_build_context_synchronously
                      Fluttertoast.showToast(
                        msg: 'Saved Successfully',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey[800],
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      // ignore: use_build_context_synchronously
                      Utils().showSnackBar(context: context, content: output);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 230, 124, 129), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                      color: Colors.white, // Loading indicator color
                    )
                        : Text(
                      'Save',
                      style: TextStyle(
                        letterSpacing: 0.6,
                        fontSize: 18,
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

