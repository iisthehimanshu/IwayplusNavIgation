import 'package:flutter/material.dart';

class SomethingWentWrongPage extends StatelessWidget {
  final String errorMessage;
  final Function()? onRetry;

  const SomethingWentWrongPage({
    Key? key,
    this.errorMessage = 'Oops! Something went wrong.',
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80.0,
                ),
                SizedBox(height: 24.0),

                // Error title
                Text(
                  'Something Went Wrong',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),

                // Error message
                Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.0),

                // Retry button
                if (onRetry != null)
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    ),
                    child: Text('Try Again'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage in your application:

class ErrorPageExample extends StatelessWidget {
  const ErrorPageExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SomethingWentWrongPage(
      errorMessage: 'We couldn\'t load the data. Please check your internet connection.',
      onRetry: () {
        // Implement your retry logic here
        print('Retrying...');
        // You might want to navigate back or reload data
        // Navigator.of(context).pop();
      },
    );
  }
}