import 'package:fix_emotion/graph/bar_graph.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'database_service.dart';
import 'camera_service.dart';
import 'model_service.dart';
import 'emotion_service.dart';

class TrackEmoLayout extends StatefulWidget {
  final String userId;

  const TrackEmoLayout({Key? key, required this.userId}) : super(key: key);

  @override
  _TrackEmoLayoutState createState() => _TrackEmoLayoutState();
}

class _TrackEmoLayoutState extends State<TrackEmoLayout> {
  final CameraService _cameraService = CameraService();
  final ModelService _modelService = ModelService();
  final EmotionService _emotionService = EmotionService();
  final DatabaseService _databaseService = DatabaseService(Supabase.instance.client);

  late Future<void> _initializationFuture;
  String _output = '';
  bool _isCameraPlaying = false;
  bool _isGraphVisible = false;
  Map<String, int> _scores = {};

  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _cameraService.initializeCamera(_processImageStream);
      print('Camera initialized successfully.');
      await _modelService.loadModel();
      print('Model loaded successfully.');
    } catch (e) {
      print('Error during initialization: $e');
    }
  }

  void _startSession() {
    setState(() {
      _isCameraPlaying = true;
      _sessionStartTime = DateTime.now();
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraPlaying = !_isCameraPlaying;
      if (_isCameraPlaying) {
        _startSession();
      }
    });
  }

  Future<void> _processImageStream(CameraImage image) async {
    if (_isCameraPlaying) {
      print('Processing image frame...');
      final emotion = await _modelService.runModelOnFrame(image);
      if (emotion.isNotEmpty) {
        setState(() {
          _output = emotion;
          _emotionService.saveEmotion(emotion);
          _scores = _emotionService.mapProbabilitiesToScores(_emotionService.calculateEmotionProbabilities());
        });
        print('Emotion detected: $_output');
      } else {
        print('No emotion detected.');
      }
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isCameraPlaying) {
          // If the camera is still playing, show a dialog to stop it first
          return await _showStopTrackingDialog(context);
        } else {
          // If the camera is not playing, allow normal back navigation
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Track Emotion')),
        body: SafeArea(
          child: FutureBuilder<void>(
            future: _initializationFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return _buildMainContent();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _toggleCamera,
                child: Center(
                  child: _cameraService.cameraPreviewWidget(),
                ),
              ),
            ),
            _buildControls(),
            ElevatedButton(
              onPressed: _endSession,
              child: const Text('End Session'),
            ),
          ],
        ),
        if (_isGraphVisible)
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(1),
                borderRadius: BorderRadius.circular(10),
              ),
              height: 150,
              width: 350,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: myBarGraph(scores: _scores),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _isGraphVisible = !_isGraphVisible;
              });
            },
            icon: const Icon(Icons.bar_chart_rounded, size: 36),
          ),
          IconButton(
            onPressed: _toggleCamera,
            icon: Icon(_isCameraPlaying ? Icons.pause : Icons.play_arrow, size: 36),
          ),
          const SizedBox(width: 16),
          Text(
            _output,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Future<void> _endSession() async {
    print('End session button pressed.');

    final sessionId = Uuid().v4();
    final sessionEndTime = DateTime.now();
    final duration = sessionEndTime.difference(_sessionStartTime!).inSeconds;

    final mostFrequentEmotion = _emotionService.getMostFrequentEmotion();
    final emotionDistribution = _emotionService.calculateEmotionProbabilities();

    try {
      await _databaseService.insertSessionData(
        userId: widget.userId,
        sessionId: sessionId,
        emotion: mostFrequentEmotion,
        emotionDistribution: emotionDistribution,
        duration: duration,
      );
      print('Session data saved successfully.');
    } catch (e) {
      print('Error during session data save: $e');
    }

    _emotionService.savedData.clear();

    setState(() {
      _isGraphVisible = false;
      _output = '';
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Ended'),
        content: const Text('Your session has been successfully saved.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    print('Session ended, data saved.');
  }

  Future<bool> _showStopTrackingDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Tracking'),
        content: const Text('The camera is still tracking emotions. Do you want to stop tracking and exit?'),
        actions: [
          TextButton(
            onPressed: () {
              _toggleCamera();
              Navigator.of(context).pop(true);
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
        ],
      ),
    ) ?? false;
  }
}
