import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelService {
  Interpreter? _interpreter;
  bool _isInterpreterBusy = false;
  List<String> _labels = ['Happiness', 'Sadness', 'Anger', 'Neutral', 'Surprise', 'Disgust', 'Fear'];

  // Load the TFLite model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/emotion_model_quantized.tflite',
        options: InterpreterOptions()..threads = 2, 
      );
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load the model: $e');
    }
  }

  // Run the model on a camera frame
  Future<String> runModelOnFrame(CameraImage image, Rect boundingBox) async {
    if (_isInterpreterBusy) {
      return '';
    }

    // Check if the interpreter is initialized
    if (_interpreter == null) {
      print("Interpreter is null! Ensure the model is loaded before inference.");
      return ''; // Exit early if interpreter is not initialized
    }

    _isInterpreterBusy = true;

    try {
      print('Starting model inference...');

      // Step 1: Convert the CameraImage to an Image package-compatible format
      img.Image convertedImage = convertCameraImageToImage(image);
      print("Step 1: Image conversion completed");

      // Step 2: Crop the image using the bounding box
      img.Image croppedImage = img.copyCrop(
        convertedImage,
        x: boundingBox.left.toInt(),
        y: boundingBox.top.toInt(),
        width: boundingBox.width.toInt(),
        height: boundingBox.height.toInt(),
      );
      print("Step 2: Cropped image using bounding box");

      // Step 3: Resize the cropped image to 224x224 as required by the model
      img.Image resizedImage = img.copyResize(croppedImage, width: 224, height: 224);
      print("Step 3: Resized image to 224x224");

      // Step 4: Normalize the image data (convert to Float32List)
      Float32List inputData = processImage(resizedImage);
      print("Step 4: Image normalization completed. Input data length: ${inputData.length}");

      // Step 5: Reshape the input data to match the model's input shape [1, 224, 224, 3]
      inputData = reshapeInput(inputData, [1, 224, 224, 3]);

      print("Input data reshaped to [1, 224, 224, 3]");

      // Step 6: Run model inference
      List<List<double>> output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
      _interpreter!.run(inputData.buffer.asUint8List(), output);
      print("Step 6: Model inference completed");

      // Step 7: Process the output and return the label
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

  // Convert CameraImage (grayscale) to img.Image (RGB)
  img.Image convertCameraImageToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    // Create an img.Image object for manipulation
    img.Image imgBuffer = img.Image(width: width, height: height);

    // Get the Y plane (grayscale)
    final Uint8List yPlane = cameraImage.planes[0].bytes;

    // Convert the Y plane to RGB by setting R, G, B to Y's value
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        final int yIndex = i * width + j;
        final int y = yPlane[yIndex];

        // Set R, G, and B to Y's value (grayscale to RGB conversion)
        imgBuffer.setPixelRgba(j, i, y, y, y, 255);
      }
    }

    return imgBuffer;
  }

  // Preprocess image data (resize, normalize, convert to Float32List)
  Float32List processImage(img.Image image) {
    // Normalize the image to values between 0 and 1, and convert to float
    List<double> imageAsFloatList = image
        .getBytes() // Get pixel values in RGB format
        .map((pixel) => pixel.toDouble() / 255.0) // Normalize to 0-1
        .toList();

    return Float32List.fromList(imageAsFloatList);
  }

  // Function to reshape input to [1, 224, 224, 3]
  Float32List reshapeInput(Float32List input, List<int> shape) {
    // The model expects input shape [1, 224, 224, 3]
    // Ensure that the input data length matches the expected shape
    final int expectedLength = shape.reduce((a, b) => a * b);

    if (input.length != expectedLength) {
      throw Exception("Cannot reshape array of length ${input.length} into shape $shape (expected length: $expectedLength)");
    }
    
    return input;
  }
}
