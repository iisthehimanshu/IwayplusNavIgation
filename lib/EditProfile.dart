

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:quickalert/quickalert.dart';
import 'ChangePassword.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
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
    print("signInBox.values");
    print(signInBox.values);

    setState(() {
      userId = signInBox.get("userId");
      accessToken = signInBox.get('accessToken');
      refreshToken = signInBox.get('refreshToken');
    });

    if (userId != null) {
      getUserDetails();
    } else {
      print("User id is null");
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
        _emailController.text = responseBody["username"];
        originalName = responseBody["name"];

        print("originalName");
        print(originalName);
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



  // Future<void> updateUser() async {
  //   final String updateUrl = "https://dev.iwayplus.in/secured/user/update/$userId";
  //
  //   try {
  //     final response = await http.put(
  //       Uri.parse(updateUrl),
  //       body: json.encode({
  //         "email": _emailController.text,
  //         "name": _nameController.text,
  //       }),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'x-access-token': '$accessToken',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Handle successful update
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Name updated successfully')),
  //       );
  //       Navigator.pop(context);
  //     } else if (response.statusCode == 403) {
  //       // Access token expired, refresh token and retry the call
  //       await refreshTokenAndRetry(updateUrl);
  //     } else {
  //       // Handle other status codes
  //     }
  //   } catch (e) {
  //     // Handle errors
  //   }
  // }
  Future<void> updateUser(BuildContext context) async {
    final String updateUrl = "https://dev.iwayplus.in/secured/user/update/$userId";

    // Show a loading indicator
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Updating',
      text: 'Please wait...',
      barrierDismissible: false,
    );

    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        body: json.encode({
          "email": _emailController.text,
          "name": _nameController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );

      Navigator.of(context).pop(); // Close the loading indicator

      if (response.statusCode == 200) {
        // Show success alert
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Name updated successfully',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      } else if (response.statusCode == 403) {
        // Access token expired, refresh token and retry the call
        await refreshTokenAndRetry(updateUrl);
      } else {
        // Handle other status codes
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Failed to update name. Please try again.',
          confirmBtnText: 'OK',
        );
      }
    } catch (e) {
      // Handle errors
      Navigator.of(context).pop(); // Close the loading indicator if an error occurs
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'An error occurred while updating. Please try again.',
        confirmBtnText: 'OK',
      );
    }
  }

  Future<void> refreshTokenAndRetry(String updateUrl) async {
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
        final signInBox = await Hive.openBox('SignInDatabase');
        signInBox.put('accessToken', accessToken);


        await updateUserWithNewToken(updateUrl);
      } else {
        // Handle token refresh failure
      }
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> updateUserWithNewToken(String updateUrl) async {
    try {
      final response = await http.put(
        Uri.parse(updateUrl),
        body: json.encode({
          "email": _emailController.text,
          "name": _nameController.text,
        }),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': '$accessToken',
        },
      );

      if (response.statusCode == 200) {
        // Handle successful update after token refresh
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Name updated successfully')),
        );
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
        centerTitle: true,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: isLoading
              ? CircularProgressIndicator()
              :Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Stack(
              //   children: [
              //     Container(
              //       width: 150,
              //       height: 150,
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: Colors.blueGrey,
              //         image: DecorationImage(
              //           image: AssetImage('assets/profilePageAssets/User image.png'),
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              //     ),
              //     Positioned(
              //       bottom: 0,
              //       right: 0,
              //       child: Container(
              //         decoration: BoxDecoration(
              //           color: Colors.black,
              //           shape: BoxShape.circle,
              //         ),
              //         child:
              //         IconButton(
              //           icon: Icon(Icons.camera_alt,color: Colors.white,),
              //           onPressed: null,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      enabled: false,
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 20,),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePasswordScreen(email: _emailController.text,)),
                      );
                    },
                    child: Text(
                      'Change password',
                      style: TextStyle(
                        color: Color(0xFF0B6B94),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.36),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: OutlinedButton(
                      onPressed: () {
                        if (_nameController.text != originalName) {
                          // Call updateUser only if the name has changed
                          updateUser(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: BorderSide(color: Color(0xFF0B6B94)),
                      ),
                      child: Text(
                        'Save changes',
                        style: TextStyle(
                          color: Color(0xFF0B6B94),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
