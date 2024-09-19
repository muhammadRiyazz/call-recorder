import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static const platform = MethodChannel('call.recording.app/recording');

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  String _currentFilePath = '';

  @override
  void initState() {
    super.initState();

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _duration = duration ?? Duration.zero;
      });
    });
  }

  // Function to initiate a call
  Future<void> startCall(String number) async {
    try {
      await MyApp.platform.invokeMethod('startCall', {'number': number});
    } on PlatformException catch (e) {
      log("Failed to start call: '${e.message}'");
    }
  }

  // Function to get the list of recorded files
  Future<List<String>> getRecordedCalls() async {
    try {
      final List<dynamic> recordings = await MyApp.platform.invokeMethod('getRecordings');
      return recordings.cast<String>(); // Ensure correct casting
    } on PlatformException catch (e) {
      log("Failed to get recordings: '${e.message}'");
      return [];
    }
  }

  // Function to play a recording
  void playRecording(String filePath) async {
    if (await File(filePath).exists()) {
      try {
                log("Playing file: $filePath");

        setState(() {
          _currentFilePath = filePath;
          _isPlaying = true;
        });
        log("Playing file: $filePath");
        await _audioPlayer.setFilePath(filePath);
        _audioPlayer.play();
      } catch (e) {
        log("Error playing recording: $e");
      }
    } else {
      log("File does not exist at path: $filePath");
    }
  }

  // Function to pause/resume playback
  void togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
       
        appBar: AppBar(actions: [IconButton(onPressed: (){            setState(() {});
}, icon: Icon(Icons.refresh))],
          title: const Text('Call Recording App'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                startCall('9539506229'); // Change this to the desired number
              },
              child: const Text('Call & Record'),
            ),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: getRecordedCalls(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching recordings'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No recordings found'));
                  }

                  final recordings = snapshot.data!;

                  return ListView.builder(
                    itemCount: recordings.length,
                    itemBuilder: (context, index) {
                      final recording = recordings[index];
                      return ListTile(
                        title: Text('Recording ${index + 1}'),
                        subtitle: Text(recording),
                        trailing: IconButton(
                          icon: Icon(_isPlaying && _currentFilePath == recording ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            if (_currentFilePath == recording) {
                              togglePlayPause();
                            } else {
                              playRecording(recording);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_duration > Duration.zero)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Slider(
                      min: 0.0,
                      max: _duration.inMilliseconds.toDouble(),
                      value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble()),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_position.toString().split('.').first),
                        Text(_duration.toString().split('.').first),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
