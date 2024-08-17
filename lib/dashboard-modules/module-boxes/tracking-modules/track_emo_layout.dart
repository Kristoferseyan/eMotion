import 'package:fix_emotion/graph/bar_graph.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_service.dart';
import 'model_service.dart';
import 'emotion_service.dart';

class TrackEmoLayout extends StatefulWidget {
  const TrackEmoLayout({Key? key}) : super(key: key);

  @override
  _TrackEmoLayoutState createState() => _TrackEmoLayoutState();
}

class _TrackEmoLayoutState extends State<TrackEmoLayout> {
  final CameraService _cameraService = CameraService();
  final ModelService _modelService = ModelService();
  final EmotionService _emotionService = EmotionService();

  late Future<void> _initializationFuture;
  String _output = '';
  bool _isCameraPlaying = false;
  bool _isGraphVisible = false;
  Map<String, int> _scores = {};

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
    return Scaffold(
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
                onTap: () {
                  setState(() {
                    _isCameraPlaying = !_isCameraPlaying;
                  });
                },
                child: Center(
                  child: _cameraService.cameraPreviewWidget(),
                ),
              ),
            ),
            _buildControls(),
            ElevatedButton(
              onPressed: _showSavedDataDialog,
              child: const Text('Check Saved Data'),
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
            onPressed: () {
              setState(() {
                _isCameraPlaying = !_isCameraPlaying;
              });
            },
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

  Future<void> _showSavedDataDialog() async {
    final scores = _emotionService.mapProbabilitiesToScores(_emotionService.calculateEmotionProbabilities());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Saved Data'),
          content: Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: scores.entries.map((entry) {
                return ListTile(
                  title: Row(
                    children: [
                      Text('${entry.key}: ${entry.value}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
