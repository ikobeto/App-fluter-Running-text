// tampilan.dart
import 'package:flutter/material.dart';

class waktu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waktu  Page'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Waktu!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
