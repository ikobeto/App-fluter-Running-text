// tampilan.dart
import 'package:flutter/material.dart';

class pesan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesan Page'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Pesan!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
