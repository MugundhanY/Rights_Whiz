import 'package:app_name/authentication/authentication_methods.dart';
import 'package:app_name/authentication/cloud_firestore_methods.dart';
import 'package:app_name/authentication/google_sign_in.dart';
import 'package:app_name/constants/utils.dart';
import 'package:app_name/screens/forget_password.dart';
import 'package:app_name/screens/home.dart';
import 'package:app_name/screens/landing.dart';
import 'package:app_name/screens/phone.dart';
import 'package:app_name/screens/login.dart';
import 'package:app_name/screens/phone_sign_up.dart';
import 'package:app_name/screens/signup_details.dart';
import 'package:app_name/widgets/sign_in_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  late FocusNode focusNodeemail;
  bool isInFocusemail = false;
  late FocusNode focusNodepassword;
  bool isInFocuspassword = false;
  late FocusNode focusNodecpassword;
  bool isInFocuscpassword = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();

  AuthenticationMethods authenticationMethods = AuthenticationMethods();
  bool isLoading = false;
  bool vertical = false;

  @override
  void dispose() {
    super.dispose();
    CloudFirestoreClass().getNameAndAddress();
    emailController.dispose();
    passwordController.dispose();
    cpasswordController.dispose();
  }

  var animationLink = 'assets/login-teddy.riv';
  SMITrigger? failTrigger, successTrigger;
  SMIBool? isHandsUp, isChecking;
  SMINumber? lookNum;
  StateMachineController? stateMachineController;
  Artboard? artboard;

  void initState() {
    super.initState();
    focusNodeemail = FocusNode();

    focusNodeemail.addListener(() {
      if (focusNodeemail.hasFocus) {
        setState(() {
          isInFocusemail = true;
        });
      } else {
        setState(() {
          isInFocusemail = false;
        });
      }
    });
    focusNodecpassword = FocusNode();

    focusNodecpassword.addListener(() {
      if (focusNodecpassword.hasFocus) {
        setState(() {
          isInFocuscpassword = true;
        });
      } else {
        setState(() {
          isInFocuscpassword = false;
        });
      }
    });
    focusNodepassword = FocusNode();

    focusNodepassword.addListener(() {
      if (focusNodepassword.hasFocus) {
        setState(() {
          isInFocuspassword = true;
        });
      } else {
        setState(() {
          isInFocuspassword = false;
        });
      }
    });
    rootBundle.load(animationLink).then((value) {
      final file = RiveFile.import(value);
      final art = file.mainArtboard;
      stateMachineController =
          StateMachineController.fromArtboard(art, "Login Machine");

      if (stateMachineController != null) {
        art.addController(stateMachineController!);

        stateMachineController!.inputs.forEach((element) {
          if (element.name == "isChecking") {
            isChecking = element as SMIBool;
          } else if (element.name == "isHandsUp") {
            isHandsUp = element as SMIBool;
          } else if (element.name == "trigSuccess") {
            successTrigger = element as SMITrigger;
          } else if (element.name == "trigFail") {
            failTrigger = element as SMITrigger;
          } else if (element.name == "numLook") {
            lookNum = element as SMINumber;
          }
        });
      }
      setState(() => artboard = art);
    });
  }

  void lookAround() {
    isChecking?.change(true);
    isHandsUp?.change(false);
    lookNum?.change(0);
  }

  void moveEyes(value) {
    lookNum?.change(value.length.toDouble());
  }

  void handsUpOnEyes() {
    isHandsUp?.change(true);
    isChecking?.change(false);
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFD6E2EA),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Your content goes here
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  width: 250,
                  child: Rive(artboard: artboard!),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          onChanged: ((value) => moveEyes(value)),
                          onTap: lookAround,
                          focusNode: focusNodeemail,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "E-mail",
                            prefixIcon: const Icon(Icons.mail_rounded),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.green.shade800, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1),
                            ),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          onTap: handsUpOnEyes,
                          focusNode: focusNodepassword,
                          controller: passwordController,
                          obscureText: true,
                          // to hide password
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: const Icon(Icons.lock_rounded),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.green.shade800, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                              const BorderSide(color: Colors.black, width: 1),
                            ),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          onTap: handsUpOnEyes,
                          focusNode: focusNodecpassword,
                          controller: cpasswordController,
                          obscureText: true,
                          // to hide password
                          decoration: InputDecoration(
                            hintText: "Confirm Password",
                            prefixIcon: const Icon(Icons.lock_rounded),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.green.shade800, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1),
                            ),
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: MaterialButton(
                          minWidth: size.width,
                          height: 50,
                          color: Color.fromARGB(255, 230, 124, 129),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onPressed: () async {
                            isChecking?.change(false);
                            isHandsUp?.change(false);
                            setState(() {});
                            focusNodecpassword.unfocus();
                            focusNodepassword.unfocus();
                            focusNodeemail.unfocus();
                            showLoadingDialog(context);
                            setState(() {
                              isLoading = true;
                            });
                            String output =
                            await authenticationMethods.signUpUser(
                                email: emailController.text,
                                password: passwordController.text,
                                confirmPassword: cpasswordController.text);
                            await Future.delayed(
                              const Duration(milliseconds: 2000),
                            );
                            setState(() {
                              isLoading = false;
                            });
                            if (mounted) Navigator.pop(context);
                              if (output == "success") {
                                //functions
                                print(output);
                                successTrigger?.fire();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => FirstPage()),
                                );
                              } else {
                                failTrigger?.fire();
                                Utils().showSnackBar(
                                    context: context, content: output);
                              }
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[400],
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'Or continue with',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          signInButtons(
                              onTap: () async {
                                //showLoadingDialog(context);
                                //Future.delayed(const Duration(seconds: 1));
                                String output =
                                await AuthService().signUpwithGoogle();
                                //if (mounted) Navigator.pop(context);
                                if (output == "success") {
                                  successTrigger?.fire();
                                  // ignore: use_build_context_synchronously
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => FirstPage()),
                                  );
                                } else {
                                  failTrigger?.fire();
                                  // ignore: use_build_context_synchronously
                                  Utils().showSnackBar(
                                      context: context, content: output);
                                }
                              },
                              imagePath: "assets/google.png"),
                          signInButtons(
                              onTap: () async {
                                // ignore: use_build_context_synchronously
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MyPhoneSignUp()));
                              },
                              imagePath: "assets/phone.png"),
                        ],
                      ),
                      SizedBox(height: 10),

                      // not a member? register now
                      SizedBox(
                        width: size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already a member?"),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
                              },
                              child: const Text(
                                "Login now",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Back arrow button
          Positioned(
            top: 24, // Adjust the position as needed
            left: 16, // Adjust the position as needed
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => landing()));
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
