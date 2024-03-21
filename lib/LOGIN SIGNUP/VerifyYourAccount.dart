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
import 'package:iwayplusnav/Elements/HelperClass.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/CreateNewPassword.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/ForgetPassword.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/APIS/SignInAPI.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/LOGIN%20SIGNUP%20APIS/APIS/SignUpAPI.dart';
import 'package:iwayplusnav/LOGIN%20SIGNUP/SignUp.dart';
import 'package:upgrader/upgrader.dart';
import 'package:lottie/lottie.dart' as lot;
import '../MainScreen.dart';

class VerifyYourAccount extends StatefulWidget {
  final String previousScreen;
  final String userEmailOrPhone;
  final String userName;
  final String userPasword;

  const VerifyYourAccount({required this.previousScreen,this.userEmailOrPhone='',this.userName='',this.userPasword=''});

  @override
  State<VerifyYourAccount> createState() => _VerifyYourAccountState();
}

class _VerifyYourAccountState extends State<VerifyYourAccount> {
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

  TextEditingController OTPEditingController = TextEditingController();


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

  void OTPFieldListner(){
    if(OTPEditingController.text.length>0){
      if(OTPEditingController.text.length>0){
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
        OTPEditingController.clear();
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
                                      "Verify Your Account",
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
                                  margin: EdgeInsets.only(left: 16,top: 8,right: 16),
                                  width: screenWidth,
                                  child: Flexible(
                                    child: Container(
                                      child: Text(
                                        "Please enter the verification code we’ve sent you on inwayplus@gmail.com",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xff242323),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
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
                                            keyboardType: TextInputType.number, // Set keyboard type to number
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.digitsOnly // Allow only digits
                                            ],
                                            controller: OTPEditingController,
                                            decoration: InputDecoration(
                                                hintText: 'OTP',
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
                                              OTPFieldListner();
                                              outlineheaderColorForPass = new Color(0xff49454f);
                                              outlineheaderColorForName = new Color(0xff49454f);
                                            },
                                          ),
                                        ))
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 32,top: 4),
                                  child: Text(
                                    "Enter your 6-digit otp here",
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
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(top: 4,right: 26),
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      Text(
                                        "00:59",
                                        style: const TextStyle(
                                          fontFamily: "Roboto",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff000000),
                                          height: 23/16,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  )
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
                                              if(widget.previousScreen=='ForgetPassword'){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => CreateNewPassword(),
                                                  ),
                                                );
                                              }else{
                                                  if(await SignUpAPI().signUP(widget.userEmailOrPhone, widget.userName, widget.userPasword, OTPEditingController.text)){
                                                    Navigator.pushAndRemoveUntil(context,
                                                      MaterialPageRoute(
                                                        builder: (context) => MainScreen(initialIndex: 0,)
                                                      ),(route) => false,
                                                    );
                                                  }else{
                                                  }
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
                                              'Verify OTP',
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
