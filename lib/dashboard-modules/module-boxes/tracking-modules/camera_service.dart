import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  late CameraController _cameraController;
  List<CameraDescription> _cameras = [];

  Future<void> initializeCamera(bool isFrontCamera, void Function(CameraImage image) onImageAvailable) async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw Exception('No cameras available.');
    }

    final cameraDescription = isFrontCamera
        ? _getCamera(CameraLensDirection.back)
        : _getCamera(CameraLensDirection.front);

    _cameraController = CameraController(cameraDescription, ResolutionPreset.medium);
    await _cameraController.initialize();
    _cameraController.startImageStream(onImageAvailable);
  }

  void dispose() {
    _cameraController.dispose();
  }

  CameraDescription _getCamera(CameraLensDirection direction) {
    return _cameras.firstWhere((camera) => camera.lensDirection == direction);
  }

  void startStream(void Function(CameraImage image) onImageAvailable) {
      _cameraController.startImageStream(onImageAvailable);
  }

  void stopStream() {
    _cameraController.stopImageStream();
  }

  Widget cameraPreviewWidget() {
    return CameraPreview(_cameraController);
  }
}
