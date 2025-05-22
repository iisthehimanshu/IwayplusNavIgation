import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import 'API/buildingByVenueAPI.dart';
import 'Navigation.dart';

class webHome extends StatefulWidget {
  String? Venue;
  String? source;
  webHome({required this.Venue, required this.source, super.key});

  @override
  State<webHome> createState() => _webHomeState();
}

class _webHomeState extends State<webHome> {

  bool buildingsReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBuildings();
  }

  Future<void> loadBuildings() async {
    var signInDatabaseBox = Hive.box('SignInDatabase');
    if (signInDatabaseBox.containsKey("accessToken")) {
      await Buildingbyvenueapi.findBuildings(venue: widget.Venue);
      setState(() {
        buildingsReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildingsReady?Navigation(directLandID: widget.source??"",):CircularProgressIndicator();
  }
}

class AskForIdPage extends StatefulWidget {
  const AskForIdPage({super.key});

  @override
  State<AskForIdPage> createState() => _AskForIdPageState();
}

class _AskForIdPageState extends State<AskForIdPage> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  void _submit() {
    final id = _controller.text.trim();
    if (id.isEmpty) {
      setState(() {
        _errorText = 'Please enter an ID';
      });
    } else {
      setState(() {
        _errorText = null;
      });
      context.go('/web/$id');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter ID')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please enter your ID to continue',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'ID',
                  errorText: _errorText,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

