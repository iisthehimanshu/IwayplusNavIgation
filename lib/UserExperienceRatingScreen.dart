import 'package:flutter/material.dart';
import 'package:iwaymaps/VenueSelectionScreen.dart';
import 'package:test/scaffolding.dart';

import 'Navigation.dart';

class UserExperienceRatingScreen extends StatefulWidget {
  @override
  _UserExperienceRatingScreenState createState() =>
      _UserExperienceRatingScreenState();
}

class _UserExperienceRatingScreenState
    extends State<UserExperienceRatingScreen> {
  int _rating = 0;
  String _feedback = '';
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Text(
                  'How was your experience?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Your feedback helps us improve our service.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 40),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => _rating = index + 1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 48,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 40),
                if (_rating > 0 && _rating < 4) ...[
                  Text(
                    'What can we improve?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _feedbackController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Please share your thoughts...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => setState(() => _feedback = value),
                  ),
                ],
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_rating > 0 && (_rating >= 4 || _feedback.split(' ').where((w) => w.isNotEmpty).length >= 10)) ? () {
                            // TODO: Submit feedback
                            print('Rating: $_rating');
                            if (_feedback.isNotEmpty) {
                              print('Feedback: $_feedback');
                            }
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => VenueSelectionScreen()),
                                  (Route<dynamic> route) {
                                print("RouteStack");
                                print(route);
                                return false;},
                            );
                          }
                        : null,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Submit Feedback',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
