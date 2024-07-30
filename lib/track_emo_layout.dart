import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'auth-modules/supabase_client.dart';  

class TrackEmoLayout extends StatefulWidget {
  const TrackEmoLayout({Key? key}) : super(key: key);

  @override
  _TrackEmoLayoutState createState() => _TrackEmoLayoutState();
}

class _TrackEmoLayoutState extends State<TrackEmoLayout> with SingleTickerProviderStateMixin {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isModelLoaded = false;
  String _output = '';
  bool _isCameraPlaying = false;
  late AnimationController _animationController;
  final supabase = SupabaseClientService.instance.client;
  DateTime? _sessionStartTime;
  DateTime? _sessionEndTime;
  Timer? _updateTimer;
  List<Map<String, dynamic>> _emotionBatch = []; // List for batching emotions

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _initializeCamera();
    _loadModel();
    _isCameraPlaying = false;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        print('No cameras available.');
        Fluttertoast.showToast(msg: 'No cameras available.');
        return;
      }

      final cameraDescription = _getCamera(CameraLensDirection.back);
      _cameraController = CameraController(cameraDescription, ResolutionPreset.medium);
      await _cameraController.initialize();
      setState(() {
        _isCameraInitialized = true;
      });

      if (_isCameraPlaying) {
        _startCameraStream();
      }
    } catch (e) {
      print('Error initializing camera: $e');
      Fluttertoast.showToast(msg: 'Error initializing camera. Please try again.');
    }
  }

  CameraDescription _getCamera(CameraLensDirection direction) {
    return _cameras.firstWhere((camera) => camera.lensDirection == direction);
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
      );
      setState(() {
        _isModelLoaded = true;
      });
    } catch (e) {
      print('Error loading model: $e');
      Fluttertoast.showToast(msg: 'Error loading model. Please check the paths and try again.');
    }
  }

  Future<void> _runModelOnFrame(CameraImage image) async {
    final user = supabase.auth.currentUser; // Retrieve the current user
    if (user == null) {
      print('No user is currently logged in.');
      return;
    }

    List<dynamic>? results = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90,
      numResults: 2,
      threshold: 0.1,
    );

    if (results != null && results.isNotEmpty) {
      setState(() {
        _output = results[0]['label'];
        _output = _output.replaceAll(RegExp(r'\d+'), '');
      });

      // Add the detected emotion to the batch
      _emotionBatch.add({
        'user_id': user.id, // Use the actual user ID
        'emotion': _output,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Periodically flush the batch to the database
      if (_emotionBatch.length >= 10) { // Adjust the batch size as needed
        await _flushEmotionBatch();
      }
    }
  }

  Future<void> _flushEmotionBatch() async {
    if (_emotionBatch.isEmpty) return;

    try {
      await supabase.from('emotions').insert(_emotionBatch);
      _emotionBatch.clear(); // Clear the batch after successful insertion
    } catch (e) {
      print('Error inserting emotion batch: $e');
      Fluttertoast.showToast(msg: 'Error inserting emotion batch. Please try again.');
    }
  }

  void _toggleCameraPlayPause() {
    if (_isCameraPlaying) {
      _stopCameraStream();
    } else {
      _startCameraStream();
    }
    setState(() {
      _isCameraPlaying = !_isCameraPlaying;
    });
  }

  void _startCameraStream() {
    if (_cameraController.value.isStreamingImages) return;
    _sessionStartTime = DateTime.now();
    _cameraController.startImageStream((image) {
      if (_isModelLoaded) {
        _runModelOnFrame(image);
      }
    });
  }

  void _stopCameraStream() {
    if (!_cameraController.value.isStreamingImages) return;
    _sessionEndTime = DateTime.now();
    _cameraController.stopImageStream();
    _recordSessionDuration();
    _flushEmotionBatch(); // Flush remaining emotions in the batch
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Has Been Ended')));
  }

  void _recordSessionDuration() async {
    final user = supabase.auth.currentUser; // Retrieve the current user
    if (user == null) {
      print('No user is currently logged in.');
      return;
    }

    if (_sessionStartTime != null && _sessionEndTime != null) {
      try {
        await supabase.from('session_durations').insert({
          'user_id': user.id, // Use the actual user ID
          'start_time': _sessionStartTime!.toIso8601String(),
          'end_time': _sessionEndTime!.toIso8601String(),
        });
      } catch (e) {
        print('Error recording session duration: $e');
        Fluttertoast.showToast(msg: 'Error recording session. Please try again.');
      }
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    if (_cameraController.value.isStreamingImages) {
      _cameraController.stopImageStream();
    }
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Emotion')
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _toggleCameraPlayPause,
                child: Center(
                  child: _isCameraInitialized
                      ? Stack(
                          children: [
                            Container(
                              height: 800,
                              child: CameraPreview(_cameraController),
                            ),
                          ],
                        )
                      : CircularProgressIndicator(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _toggleCameraPlayPause,
                    icon: Icon(
                      _isCameraPlaying ? Icons.pause : Icons.play_arrow,
                      size: 36,
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    _output,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
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
