import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/APIS/SendOTPAPI.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/VerifyYourAccount.dart';
import 'package:upgrader/upgrader.dart';
import 'package:lottie/lottie.dart' as lot;
import '../MainScreen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode2_1 = FocusNode();
  FocusNode _focusNode1_1 = FocusNode();
  bool otpenalbed = false;
  bool loginapifetching = false;
  bool loginapifetching2 = false;

  bool subotpclickable = false;
  bool passincorrect = false;
  bool otpincorrect = false;
  Random random = Random();
  // userdata uobj = new userdata();
  bool ispassempty = true;

  TextEditingController phoneEditingController = TextEditingController();
  TextEditingController OTPEditingController = TextEditingController();
  String passvis = 'assets/LoginScreen_PasswordEye.svg';
  bool obsecure = true;
  //CountryCode _defaultCountry = CountryCode.fromCountryCode('US');

  Color buttonColor2 = Color(0xffbdbdbd);
  Color textColor = Color(0xff777777);
  Color textColor2 = Color(0xff777777);
  String phoneNumber = '';
  String code = '';

  String initialCountry = 'IN';
  // PhoneNumber number = PhoneNumber(isoCode: 'IN');
  String initialCountry2 = 'IN';
  // PhoneNumber number2 = PhoneNumber(isoCode: 'IN');

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;



  // getConnectivity() =>
  //     subscription = Connectivity().onConnectivityChanged.listen(
  //           (ConnectivityResult result) async {
  //         isDeviceConnected = await InternetConnectionChecker().hasConnection;
  //         if (!isDeviceConnected && isAlertSet == false) {
  //           showDialogBox();
  //           setState(() => isAlertSet = true);
  //         }
  //       },
  //     );
  //
  // showDialogBox() => showCupertinoDialog<String>(
  //   context: context,
  //   builder: (BuildContext context) => CupertinoAlertDialog(
  //     title: const Text('No Connection'),
  //     content: const Text('Please check your internet connectivity'),
  //     actions: <Widget>[
  //       TextButton(
  //         onPressed: () async {
  //           Navigator.pop(context, 'Cancel');
  //           setState(() => isAlertSet = false);
  //           isDeviceConnected =
  //           await InternetConnectionChecker().hasConnection;
  //           if (!isDeviceConnected && isAlertSet == false) {
  //             showDialogBox();
  //             setState(() => isAlertSet = true);
  //           }
  //         },
  //         child: const Text('OK'),
  //       ),
  //     ],
  //   ),
  // );


  // void subotp()async{
  //   setState(() {
  //     loginapifetching2 = true;
  //   });
  //
  //   try{
  //
  //     if (OTPEditingController.text.length == 4) {
  //
  //       await verifyotpapi().verifyotp(phoneEditingController.text, OTPEditingController.text, number2.dialCode.toString()).then((value){
  //         if(value == 200){
  //           final fetchedlogindata = loginapi().fetchedData;
  //           setState(() {
  //             loginapifetching2 = false;
  //           });
  //           if (!fetchedlogindata!.data!.deleted!) {
  //             if (fetchedlogindata.data!.validateData()) {
  //               uobj.savedata("UID", {100000 + random.nextInt(900000)}.toString());
  //               Navigator.pushAndRemoveUntil(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => mainscreen(initialIndex: 0,)),
  //                     (route) => false, // Remove all routes until the new route
  //               );
  //             } else {
  //               Navigator.pushReplacement(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => UserProfile(title: "Registration Form")),
  //               );
  //             }
  //           } else {
  //             setState(() {
  //               otpincorrect = true;
  //             });
  //             print("Wrong credentials");
  //             showToast("Wrong credentials");
  //           }
  //         }else if(value == 201){
  //           setState(() {
  //             loginapifetching2 = false;
  //             otpincorrect = true;
  //           });
  //         }
  //       });
  //
  //     }
  //   }catch(e){
  //     setState(() {
  //       loginapifetching2 = false;
  //       otpincorrect = true;
  //     });
  //     print("Error occurred: $e");
  //     showToast("Failed to load data");
  //   }
  // }

  // void login() async {
  //   setState(() {
  //     loginapifetching = true;
  //   });
  //
  //   String email = mailEditingController.text;
  //   String password = passEditingController.text;
  //   print("$email   $password");
  //
  //   try {
  //     await loginapi().login(email, password);
  //     final fetchedlogindata = loginapi().fetchedData;
  //
  //     setState(() {
  //       loginapifetching = false;
  //     });
  //
  //     if (!fetchedlogindata!.data!.deleted!) {
  //       if (fetchedlogindata.data!.validateData()) {
  //         uobj.savedata("UID", {100000 + random.nextInt(900000)}.toString());
  //         // Navigator.of(context).push(_createRoute());
  //
  //         Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(builder: (context) => mainscreen(initialIndex: 0,)),
  //               (route) => false, // Remove all routes until the new route
  //         );
  //       } else {
  //
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => UserProfile(title: "Registration Form")),
  //         );
  //       }
  //     } else {
  //       setState(() {
  //         passincorrect = true;
  //       });
  //       print("Wrong credentials");
  //       showToast("Wrong credentials");
  //     }
  //   } catch (e) {
  //     setState(() {
  //       loginapifetching = false;
  //       passincorrect = true;
  //     });
  //     print("Error occurred: $e");
  //     showToast("Failed to load data");
  //   }
  // }


  TextEditingController passEditingController = TextEditingController();
  TextEditingController mailEditingController = TextEditingController();
  TextEditingController nameEditingController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();


  Color button1 = new Color(0xff777777);
  Color text1 = new Color(0xff777777);

  Color outlineheaderColor = new Color(0xff49454f);
  Color outlineTextColor = new Color(0xff49454f);

  Color outlineheaderColorForPass = new Color(0xff49454f);
  Color outlineTextColorForPass = new Color(0xff49454f);

  bool loginclickable = false;
  Color buttonBGColor = new Color(0xff24b9b0);

  Color outlineheaderColorForName = new Color(0xff49454f);
  Color outlineTextColorForName = new Color(0xff49454f);

  void nameFiledListner(){
    if(nameEditingController.text.length>0){
      setState(() {
        outlineheaderColorForName = Color(0xff24b9b0);// Change the button color to green
        outlineTextColorForName = Color(0xff24b9b0);// Change the button color to green
      });
    }else if(nameEditingController.text.length>0 && mailEditingController.text.length>0 && passEditingController.text.length>0){
      setState(() {
        buttonBGColor = Color(0xff24b9b0);
      });

    }else{
      setState(() {
        outlineheaderColorForName = Color(0xff49454f);
        outlineTextColorForName = Color(0xff49454f);
        buttonBGColor = Color(0xffbdbdbd);
      });
    }
  }

  void emailFieldListner(){
    if(mailEditingController.text.length>0){
      if(passEditingController.text.length>0){
        setState(() {
          buttonBGColor = Color(0xff24b9b0);
          loginclickable = true;
        });
      }
      setState(() {
        outlineheaderColor = Color(0xff24b9b0);// Change the button color to green
        outlineTextColor = Color(0xff24b9b0);// Change the button color to green
      });
    }else{
      setState(() {
        outlineheaderColor = Color(0xff49454f);
        outlineTextColor = Color(0xff49454f);
        buttonBGColor = Color(0xffbdbdbd);
      });
    }
  }
  void passwordFieldListner(){
    if(passEditingController.text.length>0){
      if(mailEditingController.text.length>0){
        setState(() {
          buttonBGColor = Color(0xff24b9b0);
          loginclickable = true;
        });
      }
      setState(() {
        outlineheaderColorForPass = Color(0xff24b9b0);// Change the button color to green
        outlineTextColorForPass = Color(0xff24b9b0);// Change the button color to green
      });
    }else{
      setState(() {
        outlineheaderColorForPass = Color(0xff49454f);
        outlineTextColorForPass = Color(0xff49454f);
        buttonBGColor = Color(0xffbdbdbd);
      });
    }
  }
  void signINButtonControler(){
    setState(() {
      buttonBGColor = Color(0xff24b9b0);
    });
  }

  signInWithGoogle() async{
    GoogleSignInAccount? googlUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googlUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken
    );
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    print('Google user name ${userCredential.user?.displayName}');

    if(userCredential.user != null){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0,)));
    }
  }


  void showpassword() {
    setState(() {
      obsecure = !obsecure;
      obsecure
          ? passvis = "assets/passnotvis.svg"
          : passvis = "assets/passvis.svg";
    });
  }

  @override
  void initstate() {
    super.initState();
    _focusNode1.addListener(_onFocusChange);
    _focusNode2.addListener(_onFocusChange);
    _focusNode1_1.addListener(_onFocusChange);
    _focusNode2_1.addListener(_onFocusChange);
  }



  void _onFocusChange() {
    if (_focusNode1.hasFocus) {
      setState(() {
        phoneEditingController.clear();
      });
    } else if (_focusNode2.hasFocus || _focusNode1_1.hasFocus) {
      setState(() {
        mailEditingController.clear();
        passEditingController.clear();
      });
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading:IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Stack(
        children: [SafeArea(
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Container(
              height: (orientation == Orientation.portrait)
                  ? screenHeight-37
                  : screenWidth,
              decoration: BoxDecoration(
                color: Color(0xffffffff),
              ),
              child: Column(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  margin: EdgeInsets.fromLTRB(16, 11, 0, 0),
                                  width: double.infinity,
                                  child: Text(
                                    "Sign Up",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff000000),
                                      height: 30/24,
                                    ),
                                    textAlign: TextAlign.left,
                                  )

                              ),
                              Container(
                                //color: Colors.amberAccent,
                                  margin: EdgeInsets.only(top: 20,left: 16,right: 16),
                                  height: 58,
                                  child: Container(
                                      padding: EdgeInsets.only(left: 12),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: outlineheaderColor,width: 2),
                                        color: Color(0xfffffff),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Expanded(
                                        child: TextFormField(
                                          focusNode: _focusNode1,
                                          controller: mailEditingController,
                                          decoration: InputDecoration(
                                              hintText: 'Email or mobile number',
                                              hintStyle: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xffbdbdbd),
                                              ),
                                              border: InputBorder.none
                                            //contentPadding: EdgeInsets.symmetric(vertical: 8)
                                          ),
                                          onChanged: (value) {
                                            emailFieldListner();
                                            outlineheaderColorForPass = new Color(0xff49454f);
                                            outlineheaderColorForName = new Color(0xff49454f);
                                          },
                                        ),
                                      ))
                              ),
                              Container(
                                //color: Colors.amberAccent,
                                  margin: EdgeInsets.only(top: 20,left: 16,right: 16),
                                  height: 58,
                                  child: Container(
                                      padding: EdgeInsets.only(left: 12),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: outlineheaderColorForName,width: 2),
                                        color: Color(0xfffffff),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Expanded(
                                        child: TextFormField(
                                          focusNode: nameFocusNode,
                                          controller: nameEditingController,
                                          decoration: InputDecoration(
                                              hintText: 'Name',
                                              hintStyle: TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xffbdbdbd),
                                              ),
                                              border: InputBorder.none
                                            //contentPadding: EdgeInsets.symmetric(vertical: 8)
                                          ),
                                          onChanged: (value) {
                                            nameFiledListner();
                                            setState(() {
                                              outlineheaderColorForPass = new Color(0xff49454f);
                                              outlineheaderColor = new Color(0xff49454f);
                                            });
                                          },
                                        ),
                                      ))
                              ),
                              Container(
                                //color: Colors.amberAccent,
                                margin: EdgeInsets.only(top: 20,left: 16,right: 16),
                                height: 58,
                                child: Container(
                                  padding: EdgeInsets.only(left: 12),
                                  width: double.infinity,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: passincorrect
                                            ? Colors.redAccent
                                            : outlineheaderColorForPass,width: 2),
                                    color: Color(0xfffffff),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Container(
                                    child: TextFormField(
                                      focusNode: _focusNode1_1,
                                      controller: passEditingController,
                                      obscureText: obsecure,
                                      decoration: InputDecoration(
                                          hintText: 'Password',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xffbdbdbd),
                                          ),
                                          border: InputBorder.none
                                        //contentPadding: EdgeInsets.symmetric(vertical: 8)
                                      ),
                                      onChanged: (value) {
                                        passwordFieldListner();
                                        setState(() {
                                          outlineheaderColorForName = new Color(0xff49454f);
                                          outlineheaderColor = new Color(0xff49454f);
                                          passincorrect = false;
                                        });
                                      },
                                    ),
                                  ),),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 32,top: 4),
                                child: Text(
                                  "8 characters password required.",
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff49454f),
                                    height: 16/12,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 20,right: 16,left: 16),
                                  child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Color(0xff777777), backgroundColor: buttonBGColor,                                          // Text color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                4.0), // Button border radius
                                          ),
                                          elevation: 0,
                                        ),
                                        // onPressed: loginclickable ? login : null,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => VerifyYourAccount(previousScreen: 'SignUp',userEmail: mailEditingController.text,userName: nameEditingController.text,userPasword: passEditingController.text),
                                            ),
                                          );
                                          SendOTPAPI().sendOTP(mailEditingController.text);
                                        },
                                        child: Center(
                                          child:
                                          // loginapifetching
                                          //     ? Center(
                                          //     child: lot.Lottie.asset(
                                          //         "assets/loader.json"))
                                          //     :
                                          Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                      ))
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )]
      ),
    );
  }
}


String extractPhoneNumber(String countryCode, String fullPhoneNumber) {
  // Check if the fullPhoneNumber starts with the countryCode
  if (fullPhoneNumber.startsWith(countryCode)) {
    // Extract the phone number part without the countryCode
    return fullPhoneNumber.substring(countryCode.length).trim();
  } else {
    // If the fullPhoneNumber doesn't start with the countryCode, return the original fullPhoneNumber
    return fullPhoneNumber;
  }
}

