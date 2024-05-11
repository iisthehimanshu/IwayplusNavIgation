import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'SettingScreen.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
      body: Column(
        children: [
          Container(
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
                            'Sivaprakasam Thangaraj ',
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

                              'Sivaprakash061@gmail.com',
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
          SizedBox(height: 24,),
          Semantics(
            label: "",
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
          Semantics(
            label: "",
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

          Semantics(
            label: '',
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
          SizedBox(height: MediaQuery.sizeOf(context).height*0.32,),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: MediaQuery.sizeOf(context).width*0.9,
                child: OutlinedButton(
                  onPressed: () {
                    // Handle View Profile button press
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
