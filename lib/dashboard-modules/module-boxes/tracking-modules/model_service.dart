import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ModelService {
  bool _isInterpreterBusy = false;

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/models/model.tflite",
      labels: "assets/models/labels.txt",
    );
  }

  Future<String> runModelOnFrame(CameraImage image) async {
    if (_isInterpreterBusy) {
      // If the interpreter is busy, skip this frame
      return '';
    }

    _isInterpreterBusy = true;

    try {
      final results = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
      );

      if (results != null && results.isNotEmpty) {
        var output = results[0]['label'];
        return output.replaceAll(RegExp(r'\d+'), ''); // Clean up the label
      } else {
        return '';
      }
    } catch (e) {
      print('Error during model inference: $e');
      return '';
    } finally {
      _isInterpreterBusy = false;
    }
  }
}