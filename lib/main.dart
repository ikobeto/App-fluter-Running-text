import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:coba/tampilan.dart';
import 'package:coba/awal.dart';
import 'package:coba/display.dart';
import 'package:coba/lokasi.dart';
import 'package:coba/murojah.dart';
import 'package:coba/pesan.dart';
import 'package:coba/setting.dart';
import 'package:coba/waktu.dart';




void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP8266 WiFi Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WifiInfoScreen(),
    );
  }
}

class WifiInfoScreen extends StatefulWidget {
  const WifiInfoScreen({super.key});

  @override
  State<WifiInfoScreen> createState() => _WifiInfoScreenState();
}

class _WifiInfoScreenState extends State<WifiInfoScreen> {
  final _networkInfo = NetworkInfo();
  String _wifiName = 'Checking...';
  String _ipAddress = 'Checking...';
  bool _isConnectedToESP = false;
  
  // Konstanta untuk koneksi ESP8266
  final String _espIP = '192.168.4.1'; // IP default ESP8266 AP
  final String _espToken = "Jws.coma";


  @override
  void initState() {
    super.initState();
    _initNetworkInfo();
  }

  Future<void> _initNetworkInfo() async {
    await _getWifiInfo();
  }

  Future<bool> _verifyESPConnection() async {
    try {
      print('Verifying ESP connection with token...');
      
      final response = await http.get(
        Uri.parse('http://$_espIP/verify?token=$_espToken'),
      ).timeout(const Duration(seconds: 5)); // Tambah timeout

      print('Verification response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying token: $e');
      return false;
    }
  }

  Future<void> _getWifiInfo() async {
    try {
      var status = await Permission.locationWhenInUse.request();
      
      if (status.isGranted) {
        String? wifiName = await _networkInfo.getWifiName();
        String? ipAddress = await _networkInfo.getWifiIP();

        // Verifikasi token menggunakan endpoint
        bool isESPConnected = await _verifyESPConnection();

        if (mounted) {
          setState(() {
            _wifiName = wifiName ?? 'Not connected to WiFi';
            _ipAddress = ipAddress ?? 'No IP address';
            _isConnectedToESP = isESPConnected;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _wifiName = 'Location permission denied';
            _ipAddress = 'Location permission denied';
            _isConnectedToESP = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _wifiName = 'Error: ${e.toString()}';
          _ipAddress = 'Error getting network info';
          _isConnectedToESP = false;
        });
      }
    }
  }

  Widget _buildConnectionStatus() {
    return Row(
      children: [
        Icon(
          _isConnectedToESP ? Icons.wifi : Icons.wifi_off,
          color: _isConnectedToESP ? Colors.green : Colors.red,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          _isConnectedToESP ? 'Connected to ESP8266' : 'Not Connected to ESP8266',
          style: TextStyle(
            fontSize: 16,
            color: _isConnectedToESP ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatusmp3() {
    return Row(
      children: [
        Icon(
          _isConnectedToESP ? Icons.wifi : Icons.wifi_off,
          color: _isConnectedToESP ? Colors.green : Colors.red,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          _isConnectedToESP ? 'Connected to ESP32' : 'Not Connected to ESP32',
          style: TextStyle(
            fontSize: 16,
            color: _isConnectedToESP ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }


  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JWS LENLED'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: RefreshIndicator(
        onRefresh: _getWifiInfo,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConnectionStatus(),
                    const SizedBox(height: 16),
                    if(_isConnectedToESP) ...[
                      _buildInfoSection('WiFi Name', _wifiName),
                      const SizedBox(height: 16),
                      _buildInfoSection('IP Address', _ipAddress),
                      const SizedBox(height: 16),
                    ] else ...[
                      const Text(
                        'Tidak terhubung ke ESP32',
                        style: TextStyle(fontSize: 15, color: Colors.red),
                      ),
                    ],
                    const SizedBox(width: 40),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          AppSettings.openAppSettings(type: AppSettingsType.wifi);
                        }, 
                        child: const Text('Cari WiFi')
                      ),
                    ),  
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConnectionStatus(),
                    const SizedBox(height: 16),
                    if(_isConnectedToESP) ...[
                      _buildInfoSection('WiFi Name', _wifiName),
                      const SizedBox(height: 16),
                      _buildInfoSection('IP Address', _ipAddress),
                      const SizedBox(height: 16),
                    ] else ...[
                      const Text(
                        'Tidak terhubung ke Modul MP3',
                        style: TextStyle(fontSize: 15, color: Colors.red),
                      ),
                    ],
                    const SizedBox(width: 40),
                     
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _getWifiInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
            
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140, // Sesuaikan lebar tombol agar berbentuk kotak
                  height: 140, // Sesuaikan tinggi tombol agar berbentuk kotak
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) => awal()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Hapus padding default tombol
                      shape: RoundedRectangleBorder( // Membuat tombol berbentuk kotak
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.settings_applications, size: 24), // Atur ukuran ikon sesuai kebutuhan
                        SizedBox(height: 5), // Jarak antara ikon dan teks
                        Text('Setting Awal'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width:65), // Jarak antar tombol
                SizedBox(
                  width: 140, // Sesuaikan lebar tombol agar berbentuk kotak
                  height: 140, // Sesuaikan tinggi tombol agar berbentuk kotak
                  child: ElevatedButton(
                    onPressed: () {
                       Navigator.push(
                        context, MaterialPageRoute(builder: (context) => tampilan()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Hapus padding default tombol
                      shape: RoundedRectangleBorder( // Membuat tombol berbentuk kotak
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.smart_display, size: 24), // Atur ukuran ikon sesuai kebutuhan
                        SizedBox(height: 5), // Jarak antara ikon dan teks
                        Text('Tampilan'),
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140, // Sesuaikan lebar tombol agar berbentuk kotak
                  height: 140, // Sesuaikan tinggi tombol agar berbentuk kotak
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) => display()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Hapus padding default tombol
                      shape: RoundedRectangleBorder( // Membuat tombol berbentuk kotak
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.display_settings, size: 24), // Atur ukuran ikon sesuai kebutuhan
                        SizedBox(height: 5), // Jarak antara ikon dan teks
                        Text('Display'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width:65), // Jarak antar tombol
                SizedBox(
                  width: 140, // Sesuaikan lebar tombol agar berbentuk kotak
                  height: 140, // Sesuaikan tinggi tombol agar berbentuk kotak
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) => waktu()), 
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Hapus padding default tombol
                      shape: RoundedRectangleBorder( // Membuat tombol berbentuk kotak
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.timer, size: 24), // Atur ukuran ikon sesuai kebutuhan
                        SizedBox(height: 5), // Jarak antara ikon dan teks
                        Text('Waktu'),
                      ],
                    ),
                  ),
                ),  
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140, // Sesuaikan lebar tombol agar berbentuk kotak
                  height: 140, // Sesuaikan tinggi tombol agar berbentuk kotak
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) => pesan()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Hapus padding default tombol
                      shape: RoundedRectangleBorder( // Membuat tombol berbentuk kotak
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.message, size: 24), // Atur ukuran ikon sesuai kebutuhan
                        SizedBox(height: 5), // Jarak antara ikon dan teks
                        Text('Pesan'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width:65), // Jarak antar tombol
                SizedBox(
                  width: 140, // Sesuaikan lebar tombol agar berbentuk kotak
                  height: 140, // Sesuaikan tinggi tombol agar berbentuk kotak
                  child: ElevatedButton(
                    onPressed: () {
                     Navigator.push(
                      context, MaterialPageRoute(builder: (context) => murojah()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Hapus padding default tombol
                      shape: RoundedRectangleBorder( // Membuat tombol berbentuk kotak
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.speaker, size: 24), // Atur ukuran ikon sesuai kebutuhan
                        SizedBox(height: 5), // Jarak antara ikon dan teks
                        Text('Murojaah'),
                      ],
                    ),
                  ),
                ),  
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140, // Sesuaikan lebar tombol agar berbentuk kotak
                  height: 140, // Sesuaikan tinggi tombol agar berbentuk kotak
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) => lokasi()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Hapus padding default tombol
                      shape: RoundedRectangleBorder( // Membuat tombol berbentuk kotak
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.location_on, size: 24), // Atur ukuran ikon sesuai kebutuhan
                        SizedBox(height: 5), // Jarak antara ikon dan teks
                        Text('Lokasi'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width:65), // Jarak antar tombol
                SizedBox(
                  width: 140, // Sesuaikan lebar tombol agar berbentuk kotak
                  height: 140, // Sesuaikan tinggi tombol agar berbentuk kotak
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, MaterialPageRoute(builder: (context) => setting()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Hapus padding default tombol
                      shape: RoundedRectangleBorder( // Membuat tombol berbentuk kotak
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.wifi, size: 24), // Atur ukuran ikon sesuai kebutuhan
                        SizedBox(height: 5), // Jarak antara ikon dan teks
                        Text('Setting Wifi'),
                      ],
                    ),
                  ),
                ),  
              ],
            ),    
          ],
        ),
      ),
    );
  }

  
}