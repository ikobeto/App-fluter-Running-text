// tampilan.dart
import 'package:flutter/material.dart';

class lokasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lokasi Page'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Lokasi!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
