import 'package:app_name/constants/utils.dart';
import 'package:app_name/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_name/authentication/authentication_methods.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  TextEditingController nameController = TextEditingController();
  bool isLoading = false;
  String selectedLanguage = 'English';
  String selectedAvatar = '';
  String selectedDate = '';

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
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 220, 64, 72),
        automaticallyImplyLeading: true,
        title: Text(
          "You are few steps ahead",
          style: TextStyle(fontSize: 18),
        ),
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
                Text(
                  'What\'s your name?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Reduced name text size
                    color: Color(0xFF4303F5), // Text color
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
                        color: Color(0xFF4303F5), // Icon color
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
                    backgroundColor: Color(0xFFFF8C42), // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Text(
                      'Select Date of Birth',
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
                    color: Color(0xFF4303F5),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Language preferences',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Reduced language text size
                    color: Color(0xFF4303F5),
                  ),
                ),
                SizedBox(height: 10), // Reduced spacing
                DropdownButton<String>(
                  hint: Text(
                    'Select a Language',
                    style: TextStyle(
                      fontSize: 16, // Reduced dropdown hint text size
                      color: Color(0xFF4303F5),
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
                    color: Color(0xFF4303F5),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Select an Avatar:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20, // Reduced avatar text size
                    color: Color(0xFF4303F5),
                  ),
                ),
                SizedBox(height: 10), // Reduced spacing
                Wrap(
                  alignment: WrapAlignment.center, // Align avatars in the center
                  children: avatarList.map((avatar) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = avatar;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        width: 80, // Increased avatar size
                        height: 80, // Increased avatar size
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedAvatar == avatar
                                ? Color(0xFFFF8C42) // Selected border color
                                : Colors.transparent,
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Add your sign-in logic here
                    setState(() {
                      isLoading = true;
                    });
                    String output = await authenticationMethods.signUpUserDetails(
                        name: nameController.text,
                        dob: selectedDate,
                        language: selectedLanguage,
                        avatar: selectedAvatar);
                    setState(() {
                      isLoading = false;
                    });
                    if (output == "success") {
                      // ignore: use_build_context_synchronously
                      Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
                    } else {
                      // ignore: use_build_context_synchronously
                      Utils().showSnackBar(context: context, content: output);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF8C42), // Button color
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
                      'Play',
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