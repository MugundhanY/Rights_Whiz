import 'package:app_name/authentication/authentication_methods.dart';
import 'package:app_name/constants/utils.dart';
import 'package:app_name/screens/home.dart';
import 'package:app_name/screens/login.dart';
import 'package:app_name/screens/signup.dart';
import 'package:app_name/screens/signup_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

String phoneNumber = "";
class MyPhoneSignUp extends StatefulWidget {
  const MyPhoneSignUp({Key? key}) : super(key: key);

  static String verify = "";

  @override
  State<MyPhoneSignUp> createState() => _MyPhoneSignUpState();
}

class _MyPhoneSignUpState extends State<MyPhoneSignUp> {
  TextEditingController countryController = TextEditingController();
  AuthenticationMethods authenticationMethods = AuthenticationMethods();

  var phone = "";
  @override
  void initState() {
    // TODO: implement initState
    countryController.text = "+91";
    super.initState();
  }

 Widget build(BuildContext context) {
      Size screenSize= Utils().getScreenSize();
      final ThemeData theme = Theme.of(context);
      return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 189, 211, 232),
            automaticallyImplyLeading: true,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => signup()));
                })),
        body: SingleChildScrollView(
      child: Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          child: Image.asset('assets/phone_login.png', height: screenSize.width*0.4, width: screenSize.width*0.4),
          color: Color.fromARGB(255, 189, 211, 232),

        height: 355,
          width: screenSize.width,
      ),
        SizedBox(
          height: 50,
        ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*textWidget(text: AppConstants.helloNiceToMeetYou),
                textWidget(
                    text: AppConstants.enterMobileNumber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),


                 */
                const SizedBox(
                  height: 40,
                ),
                //!otp box
                Container(
                  width: double.infinity,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 3,
                        blurRadius: 3,
                      )
                    ],
                    borderRadius: BorderRadius.circular(8),
                  ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 40,
                          child: TextField(
                            controller: countryController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Text(
                          "|",
                          style: TextStyle(fontSize: 33, color: Colors.grey),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              onChanged: (value){
                                phone = value;
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Phone",
                              ),
                            ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 68, 243, 168),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () async{
                          phoneNumber = countryController.text+phone;
                          await FirebaseAuth.instance.verifyPhoneNumber(
                              phoneNumber: '${countryController.text+phone}',
                              verificationCompleted: (PhoneAuthCredential credential){},
                              verificationFailed:  (FirebaseAuthException e) {},
                              codeSent: (String verificationId, int? resendToken) {
                                MyPhoneSignUp.verify = verificationId;

                                Navigator.push(context, MaterialPageRoute(builder: (context) => MyVerifySignUp()));
                              },
                              codeAutoRetrievalTimeout: (String verificationId) {}
                          );
                        },
                        child: Text("Send the code")),
                  )
                  ],
                ),
          ),
              ],
            ),
          ),
        ),

    );
  }
}

class MyVerifySignUp extends StatefulWidget {
  const MyVerifySignUp({Key? key}) : super(key: key);

  @override
  State<MyVerifySignUp> createState() => _MyVerifySignUpState();
}

class _MyVerifySignUpState extends State<MyVerifySignUp> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Size screenSize= Utils().getScreenSize();
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Colors.green.shade200,
      ),
    );

    var code ="";
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 120, 162, 204),
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyPhoneSignUp()));
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/phone_login.png',
                height: 250,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Phone Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.yellow.shade900),
              ),
              SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                 defaultPinTheme: defaultPinTheme,
                 focusedPinTheme: focusedPinTheme,
                 submittedPinTheme: submittedPinTheme,

                showCursor: true,
                onChanged: (value) {
                  code = value;
                },
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                    onPressed: () async{
                      try {
                        PhoneAuthCredential credential = PhoneAuthProvider
                            .credential(
                            verificationId: MyPhoneSignUp.verify, smsCode: code);
                        await auth.signInWithCredential(credential);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => FirstPage()),
                        );
                      }
                      catch(e){
                        Utils().showSnackBar(
                            context: context, content: "Wrong OTP");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 68, 243, 168),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text("Verify Phone Number")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
