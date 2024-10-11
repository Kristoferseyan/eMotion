import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ModelService {
  bool _isInterpreterBusy = false;

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/models/emotion_model_mobilenetv2.tflite",
        labels: "assets/models/labels.txt",
        numThreads: 2,
      );
      print('Model loaded');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<String> runModelOnFrame(CameraImage image, Rect boundingBox) async {
    if (_isInterpreterBusy) {
      return '';
    }

    _isInterpreterBusy = true;

    try {
      print('Model inference started');

      // Step 1: Convert the CameraImage to an Image package-compatible format
      img.Image convertedImage = convertCameraImageToImage(image);
      print("Step 1 completed");

      // Step 2: Crop the image using the bounding box
      img.Image croppedImage = img.copyCrop(
        convertedImage,
        x: boundingBox.left.toInt(),     // Bounding box left (X)
        y: boundingBox.top.toInt(),      // Bounding box top (Y)
        width: boundingBox.width.toInt(), // Bounding box width
        height: boundingBox.height.toInt(), // Bounding box height
      );
      print("Step 2: Image cropped using bounding box");

      // Step 3: Resize the cropped image to 64x64 as expected by the model
      img.Image resizedImage = img.copyResize(croppedImage, width: 64, height: 64);
      print("Resized image dimensions: width=${resizedImage.width}, height=${resizedImage.height}");

      // Step 4: Normalize and convert the image data to float32
      List<double> imageAsFloatList = resizedImage
          .getBytes() // Get pixel values
          .map((pixel) => pixel.toDouble() / 255.0) // Normalize to 0-1
          .toList();

      print("Float list length: ${imageAsFloatList.length}");  // Should be 64 * 64 * 3 = 12,288

      // Convert the normalized data to Float32List
      Float32List inputData = Float32List.fromList(imageAsFloatList);

      // Step 5: Run model inference with the normalized image data
      final results = await Tflite.runModelOnBinary(
        binary: inputData.buffer.asUint8List(),
        numResults: 2,
        threshold: 0.1,
      );

      print('Model inference completed');
      print('Model Output: $results');

      if (results != null && results.isNotEmpty) {
        var output = results[0]['label'];
        return output.replaceAll(RegExp(r'\d+'), '');  // Clean up the label
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

  // Function to handle grayscale CameraImage
  img.Image convertCameraImageToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    // Create an image buffer of the same size as the input image
    final img.Image imgBuffer = img.Image(width: width, height: height);
    print("Step 1: Created imgBuffer with dimensions width=${imgBuffer.width}, height=${imgBuffer.height}");

    // Get the Y plane (grayscale)
    final Uint8List yPlane = cameraImage.planes[0].bytes;
    print("Y plane length: ${yPlane.length}");

    // Since the image is grayscale, treat the Y plane as the pixel values
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        final int yIndex = i * width + j;
        final int y = yPlane[yIndex];

        // Use the Y value for R, G, and B channels (grayscale)
        int r = y;
        int g = y;
        int b = y;

        // Set pixel values (alpha set to 255 for full opacity)
        imgBuffer.setPixelRgba(j, i, r, g, b, 255);
      }
    }

    print("Step 2: Grayscale to RGB conversion completed");
    return imgBuffer;
  }
}
