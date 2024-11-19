

import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEBEBEB),
                  width: 1.0,
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.grey.shade400,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
        
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Welcome to iWayplus ! This Privacy Policy outlines how we collect, use, disclose, and safeguard your personal information when you use our indoor way finding application ("App"). By using the App, you agree to the terms of this Privacy Policy',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Information We Collect',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    height: 0.10,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'We may collect the following types of information when you use our App:',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 16,),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Location Information',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.10,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  'Our App utilises GPS and Bluetooth data to provide accurate indoor navigation. This includes your devices location and proximity to Bluetooth beacons. This data helps us offer you  precise navigation guidance.',
                  style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  ),
                  ),
            ),
            SizedBox(height: 16,),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'IMU (Inertial Measurement Unit) Data: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.10,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8,),
            SizedBox(width: 16,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
              'We may access your device`s IMU sensors to gather informationabout its movement, orientation, and direction. This data contributes to improving navigation accuracy. Usage Information: We collect information about your type of disability and how you interact with the  App, such as the features you use, the paths you take, and the settings you configure. This helps us enhance your overall experience.',
                  style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  ),
                  ),
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Usage Information:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.10,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'We collect information about your type of disability and how you interact with the  App, such as the features you use, the paths you take, and the settings you configure. This helps us enhance your overall experience.',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'How We Use Your Information',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'We use the collected information for the following purposes:',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            // SizedBox(height: 8,),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Navigation Services:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            // SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'The location, Bluetooth, and IMU data we collect are used to provide indoor navigation services tailored to your needs, helping you find your way within indoor spaces.',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Improvement of Services:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
              child: Text(
                'We analyse aggregated, anonymised data to enhance our navigation algorithms and overall App performance',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,

                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Personalisation:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'We may use usage information to customise your navigation experience, suggest shortcuts, and offer relevant features based on your preferences.',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Data Sharing and Disclosure',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'We may share and disclose your information under the following circumstances:',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Legal Requirements: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'We may disclose your information to comply with applicable laws, regulations, legal  processes, or government requests.',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Protection of Rights:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
            'We may disclose your information if we believe it`s necessary to protect our rights,  privacy, safety, or the rights, privacy, or safety of others.',
        style: TextStyle(
            color: Color(0xFF505054),
        fontSize: 14,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w400,
            ),
            ),
      ),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Your Choices',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'You can take the following actions regarding your information:',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Location Services:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                ' You can enable or disable location services for the App through your device`s settings.  Opt-out: You can opt-out of sharing usage data for analytical purposes through the App`s settings.',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Security:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'We employ industry-standard security measures to protect your information from unauthorized access,  disclosure, alteration, or destruction.',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
             Row(
        children: [
          SizedBox(width: 16,),
          Text(
            'Children`s Privacy',
          style: TextStyle(
          color: Colors.black,
            fontSize: 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
          ),
              ),
        ],
      ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Our App is not intended for children under the age of We do not knowingly collect personal information from children. If you believe a child has provided us with their information, please contact us   so we can remove it.',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width:
                  16,),
                Text(
                  'Changes to this Privacy Policy',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'We may update this Privacy Policy as necessary. We will notify you of any changes by posting the updated policy within the App or through other communication methods.',
                style: TextStyle(
                  color: Color(0xFF505054),
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 16,),
                Text(
                  'Contact Us',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('If you have any questions, concerns, or requests regarding this Privacy Policy, please contact us at info@iwayplus.com. By using our App, you consent to the terms of this Privacy Policy.'),
            )


        
          ],
        ),
      ),
    );
  }
}
