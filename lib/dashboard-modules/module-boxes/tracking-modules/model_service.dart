import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelService {
  Interpreter? _interpreter;
  bool _isInterpreterBusy = false;
  List<String> _labels = ['Happiness', 'Sadness', 'Anger', 'Neutral', 'Surprise', 'Disgust', 'Fear'];

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/emotion_model_quantized.tflite',
        options: InterpreterOptions()..threads = 2, 
      );
    } catch (e) {
      print('Failed to load the model: $e');
    }
  }

  Future<String> runModelOnFrame(CameraImage image, Rect boundingBox) async {
    if (_isInterpreterBusy) {
      return '';
    }

    if (_interpreter == null) {
      print("Interpreter is null! Ensure the model is loaded before inference.");
      return ''; 
    }

    _isInterpreterBusy = true;

    try {
      img.Image convertedImage = convertCameraImageToImage(image);
      img.Image croppedImage = img.copyCrop(
        convertedImage,
        x: boundingBox.left.toInt(),
        y: boundingBox.top.toInt(),
        width: boundingBox.width.toInt(),
        height: boundingBox.height.toInt(),
      );
      img.Image resizedImage = img.copyResize(croppedImage, width: 224, height: 224);
      Float32List inputData = processImage(resizedImage);
      inputData = reshapeInput(inputData, [1, 224, 224, 3]);
      List<List<double>> output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
      _interpreter!.run(inputData.buffer.asUint8List(), output);

      if (output.isNotEmpty && output[0].isNotEmpty) {
        int maxIndex = output[0].indexWhere((probability) => probability == output[0].reduce((a, b) => a > b ? a : b));
        return _labels[maxIndex];
      }
      return '';
    } catch (e) {
      print('Error during inference: $e');
      return '';
    } finally {
      _isInterpreterBusy = false;
    }
  }

  img.Image convertCameraImageToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    img.Image imgBuffer = img.Image(width: width, height: height);
    final Uint8List yPlane = cameraImage.planes[0].bytes;
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        final int yIndex = i * width + j;
        final int y = yPlane[yIndex];
        imgBuffer.setPixelRgba(j, i, y, y, y, 255);
      }
    }
    return imgBuffer;
  }
  Float32List processImage(img.Image image) {
    
    List<double> imageAsFloatList = image
        .getBytes() 
        .map((pixel) => pixel.toDouble() / 255.0) 
        .toList();

    return Float32List.fromList(imageAsFloatList);
  }
  Float32List reshapeInput(Float32List input, List<int> shape) {
    final int expectedLength = shape.reduce((a, b) => a * b);
    if (input.length != expectedLength) {
      throw Exception("Cannot reshape array of length ${input.length} into shape $shape (expected length: $expectedLength)");
    }
    return input;
  }
}
