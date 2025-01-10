import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class tampilan extends StatefulWidget {
  const tampilan({Key? key}) : super(key: key);

  @override
  State<tampilan> createState() => _CheckboxWithMediaState();
}

class _CheckboxWithMediaState extends State<tampilan> {
  List<bool> isChecked = List.generate(3, (index) => false);
  Map<int, VideoPlayerController> videoControllers = {};
  Map<int, bool> showControls = {};
  Map<int, Timer?> controlTimers = {};

  final double mediaHeight = 200.0;
  final double mediaWidth = 350.0;

  final List<Map<String, String>> items = [
    {
      'title': 'Tampilan 1',
      'media': 'assets/img/bd4.png',
      'description': 'Tampilan dengan gambar',
      'type': 'image'
    },
    {
      'title': 'Tampilan 2',
      'media': 'assets/video/vid.mp4',
      'description': 'Tampilan dengan video',
      'type': 'video'
    },
    {
      'title': 'Tampilan 3',
      'media': 'assets/img/coba.png',
      'description': 'Tampilan dengan gambar',
      'type': 'image'
    },
  ];

  void showControlsTemporarily(int index) {
    setState(() {
      showControls[index] = true;
    });

    // Cancel existing timer if any
    controlTimers[index]?.cancel();

    // Start new timer
    controlTimers[index] = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showControls[index] = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < items.length; i++) {
      if (items[i]['type'] == 'video') {
        showControls[i] = false;
        final controller = VideoPlayerController.asset(items[i]['media']!)
          ..initialize().then((_) {
            setState(() {});
          });
        videoControllers[i] = controller;

        // Listener untuk memperbarui UI saat video selesai
        controller.addListener(() {
          if (controller.value.position >= controller.value.duration) {
            setState(() {
              showControls[i] = true;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in videoControllers.values) {
      controller.dispose();
    }
    for (var timer in controlTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  Widget _buildMedia(String path, String type, int index) {
    if (type == 'video') {
      final controller = videoControllers[index];
      if (controller == null) return const SizedBox();
      if (!controller.value.isInitialized) {
        return SizedBox(
          height: mediaHeight,
          width: mediaWidth,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      return Center(
        child: GestureDetector(
          onTap: () {
            if (controller.value.isPlaying) {
              controller.pause();
              showControls[index] = true;
            } else {
              controller.play();
              showControlsTemporarily(index);
            }
            setState(() {});
          },
          child: MouseRegion(
            onHover: (_) {
              showControlsTemporarily(index);
            },
            child: SizedBox(
              height: mediaHeight,
              width: mediaWidth,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Container(
                      color: Colors.black,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: controller.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      ),
                    ),
                  ),
                  if (showControls[index] == true)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 50,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (controller.value.isPlaying) {
                              controller.pause();
                              showControls[index] = true;
                            } else {
                              controller.play();
                              showControlsTemporarily(index);
                            }
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Container(
          height: mediaHeight,
          width: mediaWidth,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Image.asset(
            path,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: mediaHeight,
                width: mediaWidth,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.error),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Tampilan'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Checkbox(
                    value: isChecked[index],
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked[index] = value!;
                        if (value) {
                          videoControllers.values.forEach((controller) {
                            controller.pause();
                            showControls[index] = true;
                          });
                          for (int i = 0; i < isChecked.length; i++) {
                            if (i != index) {
                              isChecked[i] = false;
                            }
                          }
                        }
                      });
                    },
                  ),
                  title: Text(
                    items[index]['title']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(items[index]['description']!),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildMedia(
                      items[index]['media']!,
                      items[index]['type']!,
                      index,
                    ),
                  ),
                ),
                if (items[index]['type'] == 'video' &&
                    videoControllers[index]?.value.isInitialized == true)
                  Container(
                    width: mediaWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: VideoProgressIndicator(
                      videoControllers[index]!,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final selectedItems = items
              .asMap()
              .entries
              .where((entry) => isChecked[entry.key])
              .map((entry) => entry.value['title'])
              .toList();

          if (selectedItems.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Silakan pilih salah satu tampilan'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tampilan terpilih: ${selectedItems.join(", ")}'),
              ),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}