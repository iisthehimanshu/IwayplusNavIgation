import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:upgrader/upgrader.dart';
import 'package:lottie/lottie.dart' as lot;
import '../MainScreen.dart';
import 'LOGIN SIGNUP APIS/APIS/SignInAPI.dart';
import 'SignIn.dart';
import 'VerifyYourAccount.dart';
class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
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

  void showToast(String mssg) {
    Fluttertoast.showToast(
      msg: mssg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

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
  Color buttonBGColor = Color(0xffbdbdbd);

  Color outlineheaderColorForName = new Color(0xff49454f);
  Color outlineTextColorForName = new Color(0xff49454f);
  void nameFiledListner() {
    if (nameEditingController.text.length > 0) {
      setState(() {
        outlineheaderColorForName =
            Color(0xff24b9b0); // Change the button color to green
        outlineTextColorForName =
            Color(0xff24b9b0); // Change the button color to green
      });
    } else {
      setState(() {
        outlineheaderColorForName = Color(0xff49454f);
        outlineTextColorForName = Color(0xff49454f);
        buttonBGColor = Color(0xffbdbdbd);
      });
    }
  }

  void emailFieldListner() {
    if (mailEditingController.text.isNotEmpty) {
      setState(() {
        buttonBGColor = Color(0xff24b9b0);
        loginclickable = true;
      });

      setState(() {
        outlineheaderColor =
            Color(0xff24b9b0); // Change the button color to green
        outlineTextColor =
            Color(0xff24b9b0); // Change the button color to green
      });
    } else {
      setState(() {
        outlineheaderColor = Color(0xff49454f);
        outlineTextColor = Color(0xff49454f);
        buttonBGColor = Color(0xffbdbdbd);
      });
    }
  }

  void passwordFieldListner() {
    if (passEditingController.text.length > 0) {
      if (mailEditingController.text.length > 0) {
        setState(() {
          buttonBGColor = Color(0xff24b9b0);
          loginclickable = true;
        });
      }
      setState(() {
        outlineheaderColorForPass =
            Color(0xff24b9b0); // Change the button color to green
        outlineTextColorForPass =
            Color(0xff24b9b0); // Change the button color to green
      });
    } else {
      setState(() {
        outlineheaderColorForPass = Color(0xff49454f);
        outlineTextColorForPass = Color(0xff49454f);
        buttonBGColor = Color(0xffbdbdbd);
      });
    }
  }

  void signINButtonControler() {
    setState(() {
      buttonBGColor = Color(0xff24b9b0);
    });
  }

  signInWithGoogle() async {
    GoogleSignInAccount? googlUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googlUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);
    print('Google user name ${userCredential.user?.displayName}');

    if (userCredential.user != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MainScreen(
            initialIndex: 0,
          )));
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
    buttonBGColor = Color(0xffbdbdbd);
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

  bool isLoading = false;

  bool containsOnlyNumeric(String input) {
    // Regular expression to match the pattern of numeric characters
    RegExp regExp = RegExp(r'^[0-9]+$');
    return regExp.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Semantics(
              label: "Back",
              child: Icon(Icons.arrow_back)),
        ),
      ),
      body: Stack(children: [
        SafeArea(
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Container(
              height: (orientation == Orientation.portrait)
                  ? screenHeight - 37
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
                                    "Forget Password?",
                                    style: const TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff000000),
                                      height: 30 / 24,
                                    ),
                                    textAlign: TextAlign.left,
                                  )),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 16, top: 8, right: 16),
                                width: screenWidth,
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "If you’ve forgotten your password, don’t worry Enter your email or mobile number to verify",
                                      style: TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff242323),
                                      ),
                                      textAlign: TextAlign.left,
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                //color: Colors.amberAccent,
                                  margin: EdgeInsets.only(
                                      top: 20, left: 16, right: 16),
                                  height: 58,
                                  child: Container(
                                      padding: EdgeInsets.only(left: 12),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: outlineheaderColor,
                                            width: 2),
                                        color: Color(0xfffffff),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          containsOnlyNumeric(
                                              mailEditingController.text)
                                              ? CountryCodeSelector()
                                              : Text(""),
                                          Expanded(
                                            child: Semantics(
                                              label: "Enter Email or mobile number",
                                              child: ExcludeSemantics(
                                                child: TextFormField(
                                                  focusNode: _focusNode1,
                                                  controller: mailEditingController,
                                                  decoration: const InputDecoration(
                                                      hintText:
                                                      'Email or mobile number',
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
                                                    outlineheaderColorForPass =
                                                    new Color(0xff49454f);
                                                    outlineheaderColorForName =
                                                    new Color(0xff49454f);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ))),
                              Container(
                                  margin: EdgeInsets.only(
                                      top: 32, right: 16, left: 16),
                                  child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Color(0xff777777),
                                          backgroundColor:
                                          buttonBGColor, // Text color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                4.0), // Button border radius
                                          ),
                                          elevation: 0,
                                        ),
                                        // onPressed: loginclickable ? login : null,
                                        onPressed: () async {
                                          setState(() {
                                            isLoading = true;
                                          });

                                          print(mailEditingController.text);

                                          if (mailEditingController
                                              .text.isNotEmpty) {
                                            if (containsOnlyNumeric(
                                                mailEditingController.text)) {
                                              await SignInAPI.sendOtpForgetPassword('+91${mailEditingController.text}').then((value) => {
                                                if (value == 1){
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                          VerifyYourAccount(
                                                            userEmailOrPhone:
                                                            mailEditingController
                                                                .text,
                                                            previousScreen:
                                                            'ForgetPassword',
                                                          ),
                                                    ),
                                                  )
                                                }
                                                else {
                                                  showToast(
                                                      'you are not a registered user')
                                                }
                                              });
                                            }else{
                                              await SignInAPI
                                                  .sendOtpForgetPassword(
                                                  mailEditingController
                                                      .text)
                                                  .then((value) => {
                                                if (value == 1)
                                                  {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                            VerifyYourAccount(
                                                              userEmailOrPhone:
                                                              mailEditingController
                                                                  .text,
                                                              previousScreen:
                                                              'ForgetPassword',
                                                            ),
                                                      ),
                                                    )
                                                  }
                                                else
                                                  {
                                                    showToast(
                                                        'you are not a registered user')
                                                  }
                                              });
                                            }
                                          } else {
                                            showToast('enter your details');
                                          }

                                          setState(() {
                                            isLoading = false;
                                          });
                                        },
                                        child: Center(
                                          child:
                                          // loginapifetching
                                          //     ? Center(
                                          //     child: lot.Lottie.asset(
                                          //         "assets/loader.json"))
                                          //     :
                                          (isLoading)
                                              ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                              : const Text(
                                            'Send OTP',
                                            style: TextStyle(
                                              fontFamily: 'Roboto',
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight.w500,
                                              color:
                                              Color(0xffffffff),
                                            ),
                                          ),
                                        ),
                                      )))
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
        )
      ]),
    );
  }
}