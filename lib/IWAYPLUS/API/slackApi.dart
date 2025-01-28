import 'dart:convert';
import 'package:http/http.dart' as http;

// Replace with your Slack webhook URL
const String slackWebhookUrl = 'https://hooks.slack.com/services/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';

void sendErrorToSlack(String error, StackTrace? stackTrace) async {
  final message = {
    'text': 'An error occurred in Iwaymaps: $error\n\nStackTrace:\n$stackTrace\n\n\n\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++',
  };

  final response = await http.post(
    Uri.parse(slackWebhookUrl),
    headers: {
      'Content-Type': 'application/json',
      'X-Content-Type-Options': 'nosniff', // Prevent MIME sniffing
      'X-Frame-Options': 'SAMEORIGIN', // Prevent embedding in iframe
      'X-XSS-Protection': '1; mode=block', // Prevent reflected XSS attacks
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload', // Enforce HTTPS
      'Content-Security-Policy': "frame-ancestors 'self'", // Limit who can embed the app
      'Referrer-Policy': 'no-referrer', // Prevent sending referrer information
      'X-Permitted-Cross-Domain-Policies': 'none',
      'Pragma': 'no-cache',
      'Expires': '0',
    },
    body: jsonEncode(message),
  );

  if (response.statusCode != 200) {
    print('Failed to send error to Slack: ${response.statusCode}');
  }
}

void performActionOnError(String error, StackTrace stackTrace) {
  sendErrorToSlack(error, stackTrace);
}
