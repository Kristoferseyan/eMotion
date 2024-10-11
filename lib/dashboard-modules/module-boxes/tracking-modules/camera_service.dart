import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  late CameraController _cameraController;
  List<CameraDescription> _cameras = [];

  Future<void> initializeCamera(void Function(CameraImage image) onImageAvailable) async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw Exception('No cameras available.');
    }

    // Always use the back camera
    final cameraDescription = _getCamera(CameraLensDirection.back);

    _cameraController = CameraController(cameraDescription, ResolutionPreset.low);

    try {
      await _cameraController.initialize();
    } catch (e) {
      throw Exception('Failed to initialize camera: $e');
    }

    _cameraController.startImageStream(onImageAvailable);
  }

  void dispose() {
    _cameraController.dispose();
  }

  CameraDescription _getCamera(CameraLensDirection direction) {
    return _cameras.firstWhere((camera) => camera.lensDirection == direction);
  }

  Widget cameraPreviewWidget() {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(_cameraController);
  }
}
