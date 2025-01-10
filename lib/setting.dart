import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(setting());
}

class setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP8266 Master Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ESPControlPage(),
    );
  }
}

class ESPControlPage extends StatefulWidget {
  @override
  _ESPControlPageState createState() => _ESPControlPageState();
}

class _ESPControlPageState extends State<ESPControlPage> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final String espIP = "192.168.4.1"; // Ganti dengan IP ESP8266

  Future<String> updateWiFi(String ssid, String password) async {
    final url = Uri.http(espIP, '/update');
    final response = await http.post(url, body: {
      'ssid': ssid,
      'password': password,
    });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return "Error: ${response.reasonPhrase}";
    }
  }

  Future<String> startPairing() async {
    final url = Uri.http(espIP, '/pair');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return "Error: ${response.reasonPhrase}";
    }
  }

  Future<String> verifyToken(String token) async {
    final url = Uri.http(espIP, '/verify', {'token': token});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return "Invalid Token";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ESP8266 Master Control"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: ssidController,
              decoration: InputDecoration(
                labelText: "WiFi SSID",
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "WiFi Password",
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await updateWiFi(
                  ssidController.text,
                  passwordController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              },
              child: Text("Update WiFi"),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await startPairing();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              },
              child: Text("Start Pairing"),
            ),
            ElevatedButton(
              onPressed: () async {
                final token = "Jws.coma"; // Token Anda
                final result = await verifyToken(token);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              },
              child: Text("Verify Token"),
            ),
          ],
        ),
      ),
    );
  }
}
