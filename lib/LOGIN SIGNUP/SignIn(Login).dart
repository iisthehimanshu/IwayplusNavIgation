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
import 'package:iwayplusnav/Elements/HelperClass.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/APIS/SignInAPI.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/MODELS/SignInAPIModel.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/SignUp.dart';
import 'package:upgrader/upgrader.dart';
import 'package:lottie/lottie.dart' as lot;
import '../MainScreen.dart';
import 'ForgetPassword.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();
  FocusNode _focusNode1_1 = FocusNode();

  bool passincorrect = false;
  TextEditingController passEditingController = TextEditingController();
  TextEditingController mailEditingController = TextEditingController();
  String passvis = 'assets/LoginScreen_PasswordEye.svg';
  bool obsecure = true;

  //CountryCode _defaultCountry = CountryCode.fromCountryCode('US');





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

  Color button1 = new Color(0xff777777);
  Color text1 = new Color(0xff777777);

  Color outlineheaderColor = new Color(0xff49454f);
  Color outlineTextColor = new Color(0xff49454f);
  Color outlineheaderColorForPass = new Color(0xff49454f);
  Color outlineTextColorForPass = new Color(0xff49454f);
  bool loginclickable = false;
  Color buttonBGColor = new Color(0xff24b9b0);



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

  // Future<void> _launchInBrowser(Uri url) async {
  //   if (!await launchUrl(
  //     url,
  //     mode: LaunchMode.externalApplication,
  //   )) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

  @override
  void initstate() {
    super.initState();

  }



  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Orientation orientation = MediaQuery.of(context).orientation;
    return UpgradeAlert(
      upgrader: Upgrader(
        minAppVersion: '',

      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.white,
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
                                  margin: EdgeInsets.fromLTRB(16, 60, 0, 0),
                                  width: double.infinity,
                                  child: Text(
                                    "Sign in",
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
                                    child: Stack(children: [
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
                                                },
                                              ),
                                            ))
                                      ),
                                      Container(
                                        color: Colors.white,
                                        padding: EdgeInsets.fromLTRB(3, 3, 3, 3),
                                        margin: EdgeInsets.fromLTRB(26, 7, 0, 0),
                                        child: Text(
                                          'Email or mobile number',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: outlineTextColor,
                                          ),
                                        ),
                                      )
                                    ])),
                                Container(
                                    child: Stack(children: [
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
                                            child: Row(
                                              children: [
                                                Expanded(
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
                                                          color: outlineTextColorForPass,
                                                        ),
                                                        border: InputBorder.none
                                                      //contentPadding: EdgeInsets.symmetric(vertical: 8)
                                                    ),
                                                    onChanged: (value) {
                                                      passwordFieldListner();
                                                      setState(() {
                                                        passincorrect = false;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Semantics(
                                                  label:'View Password',
                                                  child: InkWell(
                                                    onTap: () {
                                                      showpassword();
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(right: 12),
                                                      child: SvgPicture.asset(passvis),
                                                      //SvgPicture.asset("assets/LoginScreen_PasswordEye.svg"),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                      Container(
                                        color: Colors.white,
                                        padding: EdgeInsets.fromLTRB(3, 3, 3, 3),
                                        margin: EdgeInsets.fromLTRB(26, 7, 0, 0),
                                        child: Text(
                                          'Password',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: passincorrect
                                                ? Colors.redAccent
                                                : outlineTextColorForPass,
                                          ),
                                        ),
                                      )
                                    ])),
                                Row(
                                  children: [
                                    passincorrect
                                        ? Container(
                                        color: Colors.white,
                                        margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                                        padding: EdgeInsets.fromLTRB(3, 3, 3, 3),
                                        child: Text(
                                          "Incorrect Password",
                                          style: const TextStyle(
                                            fontFamily: "Roboto",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.red,
                                            height: 20 / 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ))
                                        : Container(),
                                    Spacer(),
                                    Container(
                                        color: Colors.white,
                                        margin: EdgeInsets.fromLTRB(0, 0, 26, 0),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ForgetPassword(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Forgot Password?",
                                            style: const TextStyle(
                                              fontFamily: "Roboto",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff24b9b0),
                                              height: 20 / 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        )),
                                  ],
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
                                        onPressed: () async {
                                          if(mailEditingController.text.length==0 && passEditingController.text.length==0){
                                            return HelperClass.showToast("Enter details");
                                          }
                                          SignInAPIModel? signInResponse = await SignInAPI().signIN(mailEditingController.text, passEditingController.text);
                                          print("signInResponse.accessToken");
                                          print(signInResponse?.refreshToken);
                                          print(signInResponse?.accessToken);
                                          if(signInResponse == null){
                                            HelperClass.showToast("Incorrect Details");
                                          }else{
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MainScreen(initialIndex: 0,),
                                              ),
                                            );
                                            HelperClass.showToast("Sign in successful");
                                          }
                                        },
                                        child: Center(
                                          child:
                                          // loginapifetching
                                          //     ? Center(
                                          //     child: lot.Lottie.asset(
                                          //         "assets/loader.json"))
                                          //     :
                                              Text(
                                            'Sign in',
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
                    Container(
                      margin: EdgeInsets.only(top: 20,),
                      child: Text(
                        "or",
                        style: const TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff8d8c8c),
                          height: 25/16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        signInWithGoogle();
                      },
                      child: Container(
                          margin: EdgeInsets.only(top: 20,left: 16,right: 16),
                          padding: EdgeInsets.only(left: 12),
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFFB3B3B3),width: 1),
                            color: Color(0xfffffff),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 76),
                                child: Image.asset("assets/image 6.png",height: 24,), // Replace "your_image.png" with your PNG image path
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: const Text(
                                  "Sign in with google",
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff000000),
                                    height: 25/16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )),
                    ),
                    Container(
                      margin: EdgeInsets.only(top:20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(
                              "Don't have an account?",
                              style: const TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 20/14,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ),
                          Container(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUp(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign up",
                                  style: const TextStyle(
                                    fontFamily: "Roboto",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 20/14,
                                    color: Color(0xff24b9b0),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),Positioned(
            top:0,right:0,child: Container(
              child: SvgPicture.asset(
                "assets/linear.svg",
                color: Color(0xff48246C),
              )),)],
        ),
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
