// tampilan.dart
import 'package:flutter/material.dart';

class display extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Page'),
        actions: [
         IconButton(
            icon: Icon(Icons.wifi),
            onPressed: () {
              // Define what happens when the Wi-Fi icon is pressed
              print("Wi-Fi icon pressed");
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome to the Display!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
