//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:http/http.dart' as http;
//
// class ChangePasswordScreen extends StatefulWidget {
//   const ChangePasswordScreen({Key? key, required this.email}) : super(key: key);
//
//   final String email;
//
//   @override
//   _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
// }
//
// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final TextEditingController _oldPasswordController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   String? userId;
//   String? accessToken;
//   bool _obscureOldPassword = true;
//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//
//   void _toggleOldPasswordVisibility() {
//     setState(() {
//       _obscureOldPassword = !_obscureOldPassword;
//     });
//   }
//
//   void _toggleNewPasswordVisibility() {
//     setState(() {
//       _obscureNewPassword = !_obscureNewPassword;
//     });
//   }
//
//   void _toggleConfirmPasswordVisibility() {
//     setState(() {
//       _obscureConfirmPassword = !_obscureConfirmPassword;
//     });
//   }
//   Future<void> getUserIDFromHive() async {
//     final signInBox = await Hive.openBox('SignInDatabase');
//
//     setState(() {
//       userId = signInBox.get("userId");
//       accessToken = signInBox.get('accessToken');
//     });
//
//     // if (userId != null) {
//     //   // If user ID is available, call API to get user details
//     //   getUserDetails();
//     // } else {
//     //   // Handle case where user ID is missing
//     // }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     // Retrieve user ID from Hive
//     getUserIDFromHive();
//   }
//
//   Future<void> _changePassword() async {
//     final String oldPassword = _oldPasswordController.text.trim();
//     final String newPassword = _newPasswordController.text.trim();
//     final String confirmPassword = _confirmPasswordController.text.trim();
//
//     if (newPassword != confirmPassword) {
//       // Passwords do not match, show error message
//       return showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Error'),
//             content: Text('New Password and Confirm Password do not match.'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//
//     final String apiUrl = 'https://dev.iwayplus.in/secured/change-password';
//     final Map<String, String> headers = {
//       'Content-Type': 'application/json',
//       'x-access-token': '$accessToken',
//     };
//     final Map<String, String> body = {
//       'username': widget.email,
//       'oldPassword': oldPassword,
//       'newPassword': newPassword,
//     };
//
//     try {
//       final http.Response response = await http.post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: json.encode(body),
//       );
//
//       if (response.statusCode == 200) {
//         // Password changed successfully
//         // You can navigate to another screen or show a success message
//         print('Password changed successfully');
//       } else {
//         // Password change failed
//         // Show error message
//         print('Password change failed');
//       }
//     } catch (e) {
//       print('Error: $e');
//       // Handle any errors occurred during the API call
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           'Change Password ',
//           style: TextStyle(
//             color: Color(0xFF374151),
//             fontSize: 16,
//             fontFamily: 'Roboto',
//             fontWeight: FontWeight.w500,
//             height: 0.09,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               SizedBox(height: 5),
//               TextFormField(
//                 controller: _oldPasswordController,
//                 decoration: InputDecoration(
//                   labelText: 'Old Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   suffixIcon: IconButton(
//                     onPressed: _toggleOldPasswordVisibility,
//                     icon: Icon(_obscureOldPassword ? Icons.visibility_off : Icons.visibility),
//                   ),
//                 ),
//                 obscureText: _obscureOldPassword,
//               ),
//               SizedBox(height: 20),
//               TextFormField(
//                 controller: _newPasswordController,
//                 decoration: InputDecoration(
//                   labelText: 'New Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   suffixIcon: IconButton(
//                     onPressed: _toggleNewPasswordVisibility,
//                     icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
//                   ),
//                 ),
//                 obscureText: _obscureNewPassword,
//               ),
//               SizedBox(height: 20),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 decoration: InputDecoration(
//                   labelText: 'Confirm Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   suffixIcon: IconButton(
//                     onPressed: _toggleConfirmPasswordVisibility,
//                     icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
//                   ),
//                 ),
//                 obscureText: _obscureConfirmPassword,
//               ),
//               SizedBox(height: MediaQuery.of(context).size.height * 0.48),
//               OutlinedButton(
//                 onPressed: _changePassword,
//                 style: OutlinedButton.styleFrom(
//                   backgroundColor: Color(0xff0B6B94),
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   side: BorderSide(color: Color(0xFF0B6B94)),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Update Password',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key, required this.email}) : super(key: key);

  final String email;

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? userId;
  String? accessToken;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  void _toggleOldPasswordVisibility() {
    setState(() {
      _obscureOldPassword = !_obscureOldPassword;
    });
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _obscureNewPassword = !_obscureNewPassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }
  Future<void> getUserIDFromHive() async {
    final signInBox = await Hive.openBox('SignInDatabase');

    setState(() {
      userId = signInBox.get("userId");
      accessToken = signInBox.get('accessToken');
    });

    // if (userId != null) {
    //   // If user ID is available, call API to get user details
    //   getUserDetails();
    // } else {
    //   // Handle case where user ID is missing
    // }
  }

  @override
  void initState() {
    super.initState();
    // Retrieve user ID from Hive
    getUserIDFromHive();
  }

  Future<void> _changePassword() async {
    final String oldPassword = _oldPasswordController.text.trim();
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      // Passwords do not match, show error message
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('New Password and Confirm Password do not match.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    final String apiUrl = 'https://dev.iwayplus.in/secured/change-password';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'x-access-token': '$accessToken',
    };
    final Map<String, String> body = {
      'username': widget.email,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Password changed successfully
        // You can navigate to another screen or show a success message
        _showSuccessAlert();
      } else {
        // Password change failed
        // Show error message
        _showErrorAlert();
      }
    } catch (e) {
      print('Error: $e');
      // Handle any errors occurred during the API call
    }
  }

  void _showSuccessAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Password updated successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to update password. Please try again later.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Change Password ',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 0.09,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 5),
              TextFormField(
                controller: _oldPasswordController,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    onPressed: _toggleOldPasswordVisibility,
                    icon: Icon(_obscureOldPassword ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                obscureText: _obscureOldPassword,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    onPressed: _toggleNewPasswordVisibility,
                    icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                obscureText: _obscureNewPassword,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    onPressed: _toggleConfirmPasswordVisibility,
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.48),
              OutlinedButton(
                onPressed: _changePassword,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color(0xff0B6B94),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(color: Color(0xFF0B6B94)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Update Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
