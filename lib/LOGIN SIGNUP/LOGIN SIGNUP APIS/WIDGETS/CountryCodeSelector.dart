import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CountryCodeSelector extends StatefulWidget {
  @override
  _CountryCodeSelectorState createState() => _CountryCodeSelectorState();
  String get selectedCountryCode => _CountryCodeSelectorState()._selectedCountryCode;
//for update -> context.read(countryCodeProvider).state = '+1';

}

class _CountryCodeSelectorState extends State<CountryCodeSelector> {
  String _selectedCountryCode = '+91';

  String get selectedCountryCode =>
      _selectedCountryCode; // Default country code



  void _showCountryCodePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text('Select Country Code'),
          content: Container(
            width: double.maxFinite,
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCountryCode,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCountryCode = newValue!;
                  });
                  Navigator.of(context).pop();
                },
                items: <String>['+91']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showCountryCodePicker(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _selectedCountryCode,
            style: TextStyle(fontSize: 18),
          ),
          Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}