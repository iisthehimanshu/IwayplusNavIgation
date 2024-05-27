import 'dart:convert';

import 'package:easter_egg_trigger/easter_egg_trigger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:iwaymaps/API/DeleteApi.dart';
import 'package:iwaymaps/Elements/UserCredential.dart';
import 'package:iwaymaps/LOGIN%20SIGNUP/SignIn.dart';

import 'DebugToggle.dart';
import 'EditProfile.dart';
import 'FavouriteRGCIScreen.dart';
import 'Help&SupportScreen.dart';
import 'PrivacyPolicy.dart';
import 'SettingScreen.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}): super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  String? userId;
  String? accessToken;
  String? refreshToken;
  String? originalName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Retrieve user ID from Hive
    getUserIDFromHive();
  }

  Future<void> getUserIDFromHive() async {
    final signInBox = await Hive.openBox('SignInDatabase');

    setState(() {
      userId = signInBox.get("userId");
      accessToken = signInBox.get('accessToken');
      refreshToken = signInBox.get('refreshToken');
    });

    if (userId != null) {
      getUserDetails();
    } else {
    }
  }
  Future<void> getUserDetails() async {
    setState(() {
      isLoading = true;
    });
    final String baseUrl = "https://dev.iwayplus.in/secured/user/get";

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({"userId": userId}),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );

      if (response.statusCode == 200) {

        Map<String, dynamic> responseBody = json.decode(response.body);
        _emailController.text = responseBody["email"];
        originalName = responseBody["name"];
        _nameController.text = originalName!;
      } else if (response.statusCode == 403) {
        // Access token expired, refresh token and retry the call
        await refreshTokenAndRetryForGetUserDetails(baseUrl);
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      // Handle errors
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshTokenAndRetryForGetUserDetails(String baseUrl) async {
    final String refreshTokenUrl = "https://dev.iwayplus.in/api/refreshToken";

    try {
      final response = await http.post(
        Uri.parse(refreshTokenUrl),
        body: json.encode({
          "refreshToken": refreshToken,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final newAccessToken = json.decode(response.body)["accessToken"];
        setState(() {
          accessToken = newAccessToken;
        });

        await getUserDetailsWithNewToken(baseUrl);
      } else {
        // Handle token refresh failure
      }
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> getUserDetailsWithNewToken(String baseUrl) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({"userId": userId}),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        _emailController.text = responseBody["email"];
        originalName = responseBody["name"];
        _nameController.text = originalName!;
      } else {
        // Handle other status codes after token refresh
      }
    } catch (e) {
      // Handle errors after token refresh
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(
          'Account',
          style: TextStyle(
            color: Color(0xFF18181B),
            fontSize: 20,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            height: 0.07,
          ),
        ),
      ),
      body: (isLoading)?Center(child: CircularProgressIndicator(),):Column(
        children: [
          EasterEggTrigger(
            codes: [EasterEggTriggers.SwipeRight,EasterEggTriggers.SwipeRight,EasterEggTriggers.LongPress],
            action: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>DebugToggle()),
              );
            },
            child: Container(
              child: Row(
                children: [
                  Semantics(
                    label: "Profile Photo",
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0,right: 8),
                      child: Container(
                        width: 54,
                        height: 54,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/profilePageAssets/User image.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    ),
                  ),
                  Semantics(
                    label: "Name",
                    child: Container(
                      height: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${_nameController.text} ',
                              style: TextStyle(
                                color: Color(0xFF18181B),
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                height: 0.09,
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),

                          Semantics(
                            label: "Email Address",
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(

                                '${_emailController.text}',
                                style: TextStyle(

                                  color: Color(0xFF8D8C8C),
                                  fontSize: 12,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 0.12,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 24,),
          Semantics(
            label: "",
            child: InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>EditProfile()),
                );
                },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      child: Container(
                        width: 12,
                        height: 12,
                        // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                        child: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label: "",
            child: InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>FavouriteRGCIScreen()),
                );
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: Icon(Icons.favorite),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Favourite',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      child: Container(
                        width: 12,
                        height: 12,
                        // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                        child: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label: "",
            child: InkWell(
              onTap: (){ Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>SettingScreen()),
              );},
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: Icon(Icons.settings),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: Icon(Icons.keyboard_arrow_right),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label:"",
            child: InkWell(
            onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>PrivacyPolicy()),
                );
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: Icon(Icons.padding_rounded),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Terms and Privacy Policy',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: Icon(Icons.keyboard_arrow_right),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Semantics(
            label: '',
            child: InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>HelpSupportScreen()),
                );
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: Icon(Icons.question_mark_sharp),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Help and Support',
                      style: TextStyle(
                        color: Color(0xFF18181B),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: 12,
                      height: 12,
                      // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
                      child: Icon(Icons.keyboard_arrow_right),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 22),
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () async {
                var signInBox = Hive.box('SignInDatabase');
                String userid = signInBox.get("userId");
                String token = signInBox.get("accessToken");
                print("userid");
                print(signInBox.get("userId"));
                print(userid);
                print(token);
                print(signInBox.keys);
                signInBox.clear();
                print("Localdatabase cleared");
                print(signInBox.keys);
                Future<bool> response = DeleteApi.fetchPatchData();
                if(await response){
                  signInBox.clear();
                  print("Localdatabase cleared");
                  print(signInBox.keys);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                        (route) => false,
                  );
                }else{

                }
              },
              child: Text(
                'Delete Profile',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  height: 0.10,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height*0.25,),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: MediaQuery.sizeOf(context).width*0.9,
                child: OutlinedButton(
                  onPressed: () async {
                    var signInBox = Hive.box('SignInDatabase');
                    signInBox.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignIn()),
                          (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(color: Color(0xFF0B6B94)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Log out',
                        style: TextStyle(
                          color: Color(0xFF0B6B94),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 0.09,
                        ),
                      )

                    ],
                  ),
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }
}


// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       appBar: AppBar(
//         title: Text(
//           'Account',
//           style: TextStyle(
//             color: Color(0xFF18181B),
//             fontSize: 20,
//             fontFamily: 'Roboto',
//             fontWeight: FontWeight.w700,
//             height: 0.07,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Container(
//             child: Row(
//               children: [
//                 Semantics(
//                   label: "Profile Photo",
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 16.0,right: 8),
//                     child: Container(
//                       width: 54,
//                       height: 54,
//
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         image: DecorationImage(
//                           image: AssetImage('assets/profilePageAssets/User image.png'),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//
//                   ),
//                 ),
//                 Semantics(
//                   label: "Name",
//                   child: Container(
//                     height: 40,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'Sivaprakasam Thangaraj ',
//                             style: TextStyle(
//                               color: Color(0xFF18181B),
//                               fontSize: 16,
//                               fontFamily: 'Roboto',
//                               fontWeight: FontWeight.w500,
//                               height: 0.09,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10,),
//
//                         Semantics(
//                           label: "Email Address",
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: Text(
//
//                               'Sivaprakash061@gmail.com',
//                               style: TextStyle(
//
//                                 color: Color(0xFF8D8C8C),
//                                 fontSize: 12,
//                                 fontFamily: 'Roboto',
//                                 fontWeight: FontWeight.w400,
//                                 height: 0.12,
//                               ),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//           SizedBox(height: 24,),
//           Semantics(
//             label: "",
//             child: InkWell(
//               onTap: (){
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>EditProfile()),
//                 );
//                 },
//               child: Container(
//                 width: MediaQuery.sizeOf(context).width,
//                 height: 50,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 30,
//                       height: 30,
//                       // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
//                       child: Icon(Icons.person),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Edit Profile',
//                       style: TextStyle(
//                         color: Color(0xFF18181B),
//                         fontSize: 16,
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w500,
//                         height: 0.10,
//                       ),
//                     ),
//                     Spacer(),
//                     Container(
//                       width: 12,
//                       height: 12,
//                       child: Container(
//                         width: 12,
//                         height: 12,
//                         // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
//                         child: Icon(Icons.keyboard_arrow_right),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Semantics(
//             label: "",
//             child: InkWell(
//               onTap: (){
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>FavouriteRGCIScreen()),
//                 );
//               },
//               child: Container(
//                 width: MediaQuery.sizeOf(context).width,
//                 height: 50,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 30,
//                       height: 30,
//                       // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
//                       child: Icon(Icons.favorite),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Favourite',
//                       style: TextStyle(
//                         color: Color(0xFF18181B),
//                         fontSize: 16,
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w500,
//                         height: 0.10,
//                       ),
//                     ),
//                     Spacer(),
//                     Container(
//                       width: 12,
//                       height: 12,
//                       child: Container(
//                         width: 12,
//                         height: 12,
//                         // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
//                         child: Icon(Icons.keyboard_arrow_right),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Semantics(
//             label: "",
//             child: InkWell(
//               onTap: (){ Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) =>SettingScreen()),
//               );},
//               child: Container(
//                 width: MediaQuery.sizeOf(context).width,
//                 height: 50,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 30,
//                       height: 30,
//                       // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
//                       child: Icon(Icons.settings),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Settings',
//                       style: TextStyle(
//                         color: Color(0xFF18181B),
//                         fontSize: 16,
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w500,
//                         height: 0.10,
//                       ),
//                     ),
//                     Spacer(),
//                     Container(
//                       width: 12,
//                       height: 12,
//                       // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
//                       child: Icon(Icons.keyboard_arrow_right),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Semantics(
//             label:"",
//             child: InkWell(
//             onTap: (){
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>PrivacyPolicy()),
//                 );
//               },
//               child: Container(
//                 width: MediaQuery.sizeOf(context).width,
//                 height: 50,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 30,
//                       height: 30,
//                       // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
//                       child: Icon(Icons.padding_rounded),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Terms and Privacy Policy',
//                       style: TextStyle(
//                         color: Color(0xFF18181B),
//                         fontSize: 16,
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w500,
//                         height: 0.10,
//                       ),
//                     ),
//                     Spacer(),
//                     Container(
//                       width: 12,
//                       height: 12,
//                       // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
//                       child: Icon(Icons.keyboard_arrow_right),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           Semantics(
//             label: '',
//             child: InkWell(
//               onTap: (){
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>HelpSupportScreen()),
//                 );
//               },
//               child: Container(
//                 width: MediaQuery.sizeOf(context).width,
//                 height: 50,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 30,
//                       height: 30,
//                       // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
//                       child: Icon(Icons.question_mark_sharp),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       'Help and Support',
//                       style: TextStyle(
//                         color: Color(0xFF18181B),
//                         fontSize: 16,
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w500,
//                         height: 0.10,
//                       ),
//                     ),
//                     Spacer(),
//                     Container(
//                       width: 12,
//                       height: 12,
//                       // decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
//                       child: Icon(Icons.keyboard_arrow_right),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(left: 22),
//             alignment: Alignment.centerLeft,
//             child: TextButton(
//               onPressed: () async {
//                 var signInBox = Hive.box('SignInDatabase');
//                 String userid = signInBox.get("userId");
//                 String token = signInBox.get("accessToken");
//                 print("userid");
//                 print(signInBox.get("userId"));
//                 print(userid);
//                 print(token);
//                 print(signInBox.keys);
//                 signInBox.clear();
//                 print("Localdatabase cleared");
//                 print(signInBox.keys);
//                 Future<bool> response = DeleteApi.fetchPatchData();
//                 if(await response){
//                   signInBox.clear();
//                   print("Localdatabase cleared");
//                   print(signInBox.keys);
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => SignIn()),
//                         (route) => false,
//                   );
//                 }else{
//
//                 }
//               },
//               child: Text(
//                 'Delete Profile',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: 16,
//                   fontFamily: 'Roboto',
//                   fontWeight: FontWeight.w500,
//                   height: 0.10,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: MediaQuery.sizeOf(context).height*0.25,),
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//
//               Container(
//                 width: MediaQuery.sizeOf(context).width*0.9,
//                 child: OutlinedButton(
//                   onPressed: () async {
//                     var signInBox = Hive.box('SignInDatabase');
//                     signInBox.clear();
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (context) => SignIn()),
//                           (route) => false,
//                     );
//                   },
//                   style: OutlinedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     side: BorderSide(color: Color(0xFF0B6B94)),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment:
//                     CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Log out',
//                         style: TextStyle(
//                           color: Color(0xFF0B6B94),
//                           fontSize: 16,
//                           fontFamily: 'Roboto',
//                           fontWeight: FontWeight.w500,
//                           height: 0.09,
//                         ),
//                       )
//
//                     ],
//                   ),
//                 ),
//               ),
//
//             ],
//           ),
//
//         ],
//       ),
//     );
//   }
// }