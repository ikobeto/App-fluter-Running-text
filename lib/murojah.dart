import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class murojah extends StatefulWidget {
  @override
  _MurojahState createState() => _MurojahState();
}

class _MurojahState extends State<murojah> {
  List<String> songs = [];
  double volume = 20.0;
  bool isPlaying = false;
  int currentTrack = 0;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchSongs();
  }

  // Fungsi untuk mengambil daftar lagu dari DFPlayer Mini melalui ESP8266
  Future<void> fetchSongs() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.4.1/list'),
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout connecting to ESP8266');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          songs = data.map((item) => item.toString()).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch songs: Server error';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  // Fungsi untuk memutar lagu
  Future<void> playSong(String song) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.4.1/play'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Jws.coma',
        },
        body: json.encode({
          "track": songs.indexOf(song) + 1,
          "volume": volume.toInt()
        }),
      ).timeout(
        Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Timeout playing song');
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isPlaying = true;
          currentTrack = songs.indexOf(song);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Now playing: $song')),
        );
      } else {
        throw Exception('Failed to play song');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Fungsi untuk menghentikan pemutaran
  Future<void> stopPlaying() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.4.1/stop'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Jws.coma',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isPlaying = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping playback: ${e.toString()}')),
      );
    }
  }

  // Fungsi untuk mengatur volume
  Future<void> setVolume(double newVolume) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.4.1/volume'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Jws.coma',
        },
        body: json.encode({
          "volume": newVolume.toInt()
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          volume = newVolume;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting volume: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Murojah Player'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchSongs,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: fetchSongs,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Text('${index + 1}'),
                            title: Text(songs[index]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (currentTrack == index && isPlaying)
                                  Icon(Icons.music_note, color: Colors.blue),
                                IconButton(
                                  icon: Icon(
                                    currentTrack == index && isPlaying
                                        ? Icons.stop
                                        : Icons.play_arrow,
                                  ),
                                  onPressed: () {
                                    if (currentTrack == index && isPlaying) {
                                      stopPlaying();
                                    } else {
                                      playSong(songs[index]);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Volume: ${volume.toInt()}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Slider(
                            value: volume,
                            min: 0,
                            max: 30,
                            divisions: 30,
                            label: volume.toInt().toString(),
                            onChanged: (value) {
                              setState(() {
                                volume = value;
                              });
                            },
                            onChangeEnd: (value) {
                              setVolume(value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}