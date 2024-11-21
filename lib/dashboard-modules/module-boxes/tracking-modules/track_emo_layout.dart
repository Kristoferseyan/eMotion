import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fix_emotion/graph/bar_graph.dart';
import 'package:fix_emotion/pose-detection/painters/pose_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';  
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';
import 'model_service.dart';
import 'emotion_service.dart';


class TrackEmoLayout extends StatefulWidget {
  final String userId;
  const TrackEmoLayout({super.key, required this.userId});

  @override
  State<TrackEmoLayout> createState() => _TrackEmoLayoutState();
}

class _TrackEmoLayoutState extends State<TrackEmoLayout> {
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  final ModelService _modelService = ModelService(); 
  final EmotionService _emotionService = EmotionService(); 
  final DatabaseService _databaseService = DatabaseService(Supabase.instance.client);

  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  bool _isBusy = false; 
  bool _isInterpreterBusy = false; 
  CustomPaint? _customPaint;
  Map<String, int> _scores = {};

  bool _isCameraPlaying = false;
  bool _isGraphVisible = false;
  String? detectedEmotion = '';
  late final String _userId;

  DateTime? _sessionStartTime;
  final Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  bool _saveSessionAsVideo = false;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _initialize();
    _loadModel(); 
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == CameraLensDirection.back) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1 && _isCameraPlaying) {
      await _startLiveFeed();
    }
  }

  void _loadModel() async {
    try {
      debugPrint('model loaded');
      await _modelService.loadModel();
      debugPrint('Model loaded'); 
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    _poseDetector.close();
    _controller?.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Track Emotion'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldExit = await _onWillPop();
              if (shouldExit) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              _liveFeedBody(),
              if (_isGraphVisible)
                Positioned(
                  bottom: 10,
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
                      child: MyBarGraph(scores: _scores), 
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                left: 10,
                child: Text(
                  'Detected Emotion: $detectedEmotion',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 110.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: _toggleGraphVisibility,
                    icon: const Icon(Icons.bar_chart_rounded, size: 36),
                  ),
                  IconButton(
                    onPressed: _toggleCameraPlaying,
                    icon: Icon(
                      _isCameraPlaying ? Icons.pause : Icons.play_arrow,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _saveSessionAsVideo,
                  onChanged: (bool? value) {
                    setState(() {
                      _saveSessionAsVideo = value ?? false;
                    });
                  },
                ),
                const Text('Save session as video'),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    _showInfoDialog();
                  },
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.transparent,
              child: ElevatedButton(
                onPressed: _endSession,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.white,
                ),
                child: const Text(
                  'End Session',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save session as video'),
        content: const Text('We encourage you to support eMotion by allowing us to save your current session in our very own database. This saved session will be used as new data to further improve our model\'s overall accuracy and performance, enabling it to learn continuously from your input video data, providing the oppportunity to serve our uses better. Please be assured that your saved video will be accessed exclusively by the eMotion team and will only be used for its intended purposes, ensuring your privacy and data security.'),
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
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: CameraPreview(
              _controller!,
              child: (!_saveSessionAsVideo && _customPaint != null) ? _customPaint : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await _controller?.initialize();
    if (!mounted) return;

    await _controller?.startImageStream(_processCameraImage);

    setState(() {});
  }

  Future<void> _initializeController() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    await _controller?.initialize();
    if (!mounted) return;
  }

  Future<void> _startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      await _initializeController();
    }

    if (_controller!.value.isRecordingVideo) {
      
      return;
    }

    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Storage permission not granted');
        return;
      }
      else
        print('Storage permission granted');

      await _controller!.startVideoRecording();

      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording started')),
      );

      setState(() {});
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _pauseLiveFeed() async {
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        await _controller?.stopImageStream(); 
      }
      if (_controller!.value.isRecordingVideo) {
        await _stopVideoRecording();
      }
    }
    setState(() {}); 
  }

  Future<void> _stopLiveFeed() async {
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        await _controller?.stopImageStream();
      }
      if (_controller!.value.isRecordingVideo) {
        await _stopVideoRecording();
      }
      await _controller?.dispose();
      _controller = null;
    }
  }

  Future<String?> _stopVideoRecording() async {
    try {
      final XFile videoFile = await _controller!.stopVideoRecording();

      final String? videoPath = await _saveVideoToDownloads(videoFile);

      if (videoPath != null) {
        print('Video saved to $videoPath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video saved to Downloads folder')),
        );
        final videoUrl = await _uploadVideoToSupabase(videoFile);
        if (videoUrl != null) {
          
          final mostFrequentEmotion = _emotionService.getMostFrequentEmotion();
          final emotionClass = mostFrequentEmotion.isNotEmpty ? mostFrequentEmotion : 'Neutral';

          
          await _saveVideoMetadataToSupabase(videoUrl, emotionClass);
        }
        return videoUrl;
      } else {
        print('Error saving video');
        return null;
      }
    } catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<String?> _saveVideoToDownloads(XFile videoFile) async {
    try {
      
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          print('Storage permission not granted');
          return null;
        }
        else
          print('Storage permission granted');
      }

      String filePath;
      if (Platform.isAndroid) {
        final directory = Directory('/storage/emulated/0/Download');
        final String fileName = 'tracking_session_${DateTime.now().millisecondsSinceEpoch}.mp4';
        filePath = '${directory.path}/$fileName';

        
        await videoFile.saveTo(filePath);
      } else if (Platform.isIOS) {
        
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = 'tracking_session_${DateTime.now().millisecondsSinceEpoch}.mp4';
        filePath = '${directory.path}/$fileName';

        
        await videoFile.saveTo(filePath);
      } else {
        return null;
      }
      return filePath;
    } catch (e) {
      print('Error saving video to Downloads folder: $e');
      return null;
    }
  }


void _processCameraImage(CameraImage image) async {
  if (_isBusy) {
    print('Skipping frame as system is busy');
    return; 
  }
  
  if (_saveSessionAsVideo && _controller != null && _controller!.value.isRecordingVideo) {
    return;
  }
  _isBusy = true;

  final inputImage = _inputImageFromCameraImage(image);
  if (inputImage != null) {
    try {
      
      final poses = await _poseDetector.processImage(inputImage);

      
      if (poses.isNotEmpty) {
        print("Pose detected: ${poses.length} poses found");

        
        for (var pose in poses) {
          print("Pose keypoints: ${pose.landmarks}");

          
          Rect boundingBox = calculateBoundingBox(pose.landmarks.values.toList());

          
          print("Bounding Box: Left = ${boundingBox.left}, Top = ${boundingBox.top}, Width = ${boundingBox.width}, Height = ${boundingBox.height}");

          
          if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
            final painter = PosePainter(
              poses,
              inputImage.metadata!.size,
              inputImage.metadata!.rotation,
              _controller!.description.lensDirection,
            );
            setState(() {
              _customPaint = CustomPaint(painter: painter); 
            });
          }

          
          print('Camera Image dimensions: width=${image.width}, height=${image.height}');
          print('Bounding box size: ${boundingBox.width}x${boundingBox.height}');

          
          final detectedEmotionResult = await _modelService.runModelOnFrame(image, boundingBox);

          if (detectedEmotionResult != null && detectedEmotionResult.isNotEmpty) {
            setState(() {
              detectedEmotion = detectedEmotionResult; 
            });

            
            _emotionService.saveEmotion(detectedEmotionResult);

            
            final emotionProbabilities = _emotionService.calculateEmotionProbabilities();
            _scores = _emotionService.mapProbabilitiesToScores(emotionProbabilities);

            print('Detected Emotion: $detectedEmotionResult');
            print('Emotion Scores: $_scores'); 
          }
        }
      } else {
        print("No pose detected");
      }
    } catch (e) {
      print('Error during model inference: $e');
    } finally {
      _isBusy = false; 
    }
  } else {
    _isBusy = false; 
  }
}


  
  Rect calculateBoundingBox(List<PoseLandmark> landmarks) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (var landmark in landmarks) {
      final double x = landmark.x;
      final double y = landmark.y;

      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void _endSession() async {
    final sessionId = Uuid().v4();
    final sessionEndTime = DateTime.now();
    final duration = sessionEndTime.difference(_sessionStartTime!).inSeconds;

    
    final mostFrequentEmotion = _emotionService.getMostFrequentEmotion();
    final emotionDistribution = _emotionService.calculateEmotionProbabilities();

    try {

      await _databaseService.insertSessionData(
        userId: _userId,
        sessionId: sessionId,
        emotion: mostFrequentEmotion,
        emotionDistribution: emotionDistribution,
        duration: duration,
      );

      await _stopLiveFeed();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Session Saved'),
          content: const Text('Your tracking session has been saved successfully.'),
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

      Navigator.of(context).pop();
    } catch (e) {
      print('Error during session save: $e');

      
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to save session. Error: $e'),
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
    }
    _resetUI();
  }

  void _toggleCameraPlaying() async {
    if (_isCameraPlaying) {
      await _pauseLiveFeed(); 
    } else {
      _startTracking(); 
    }
    setState(() {
      _isCameraPlaying = !_isCameraPlaying;
    });
  }

  void _startTracking() async {
    _sessionStartTime = DateTime.now(); 
    if (_saveSessionAsVideo) {
      await _initializeController();
      await _startVideoRecording();
    } else {
      await _startLiveFeed(); 
    }
    setState(() {
      _isCameraPlaying = true;
    });
    print('Tracking started');
  }

  void _toggleGraphVisibility() {
    setState(() {
      _isGraphVisible = !_isGraphVisible;
    });
  }

  void _resetUI() {
    setState(() {
      _isGraphVisible = false;
      _customPaint = null;
      detectedEmotion = ''; 
      _isCameraPlaying = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (!_isCameraPlaying) {
      return true; 
    }

    final shouldExit = await _showStopTrackingDialog(context);
    return shouldExit;
  }

  Future<bool> _showStopTrackingDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Tracking'),
        content: const Text('Tracking is still in progress. Do you want to stop and exit?'),
        actions: [
          TextButton(
            onPressed: () {
              _toggleCameraPlaying(); 
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
    ) ??
        false;
  }

  Future<String?> _uploadVideoToSupabase(XFile videoFile) async {
    try {
      final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final videoBytes = await videoFile.readAsBytes();

      await Supabase.instance.client.storage
          .from('videos_bucket')
          .uploadBinary(fileName, videoBytes, fileOptions: FileOptions(contentType: 'video/mp4'));

      print('Video uploaded to eMotion database: $fileName');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video uploaded to Supabase: $fileName')),
      );

      
      final videoUrl = Supabase.instance.client.storage
          .from('videos_bucket')
          .getPublicUrl(fileName);

      if (videoUrl != null && videoUrl.isNotEmpty) {
        print('Video URL: $videoUrl');
        return videoUrl;
      } else {
        print('Failed to get video URL');
        return null;
      }
    } catch (e) {
      print('Error uploading video to Supabase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload video: $e')),
      );
      return null;
    }
  }

  Future<void> _saveVideoMetadataToSupabase(String videoUrl, String emotionClass) async {
    try {
      final String uniqueId = Uuid().v4();

      final response = await Supabase.instance.client
          .from('videos_data')
          .insert({
        'id': uniqueId,
        'video_path': videoUrl,
        'emotion_class': emotionClass,
      });

      if (response.error != null) {
        throw response.error!;
      }

      print('Video metadata saved successfully');

    } catch (e) {
      print('Error saving video metadata: $e');
    }
  }

}
