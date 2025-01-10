import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class awal extends StatefulWidget {
  @override
  _AwalState createState() => _AwalState();
}

class _AwalState extends State<awal> {
  final TextEditingController _textController = TextEditingController();
  String _status = '';
  bool _isConnected = false;
  Timer? _connectionCheckTimer;

  // Konstanta untuk koneksi
  final String _espIP = '192.168.4.1'; // IP default ESP32 AP
  final String _token = 'Jws.coma';

  @override
  void initState() {
    super.initState();
    _checkConnection();
    // Set timer untuk mengecek koneksi secara periodik
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _checkConnection();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _connectionCheckTimer?.cancel(); // Membersihkan timer
    super.dispose();
  }

  Future<void> _checkConnection() async {
    if (!mounted) return;
    await verifyConnection();
  }

  Future<void> verifyConnection() async {
    if (!mounted) return;

    try {
      final response = await http.get(
        Uri.parse('http://$_espIP/verify?token=$_token'),
      ).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      setState(() {
        _isConnected = response.statusCode == 200;
        _status = _isConnected ? 'Terhubung ke ESP32' : 'Gagal terhubung ke ESP32';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isConnected = false;
        _status = 'Error: Pastikan terhubung ke WiFi ESP32-AP.Jws.coma';
      });
    }
  }

  Future<void> sendToESP32(String data) async {
    if (!mounted) return;

    try {
      final response = await http.post(
        Uri.parse('http://$_espIP/data'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _token,
        },
        body: json.encode({'message': data}),
      ).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      setState(() {
        if (response.statusCode == 200) {
          _status = 'Berhasil mengirim data!';
          _textController.clear();
        } else {
          _status = 'Gagal mengirim data. Status: ${response.statusCode}';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Awal Page'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: _checkConnection,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Masukkan Pesan',
                border: OutlineInputBorder(),
                hintText: 'Ketik pesan disini',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isConnected
                  ? () {
                      if (_textController.text.isNotEmpty) {
                        sendToESP32(_textController.text);
                      }
                    }
                  : null,
              child: Text('Kirim ke ESP32'),
            ),
            SizedBox(height: 20),
            Text(
              _status,
              style: TextStyle(
                color: _isConnected ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}