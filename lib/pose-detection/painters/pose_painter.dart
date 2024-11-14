import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    final leftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;

    final rightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.blueAccent;

    final boundingBoxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;  

    for (final pose in poses) {
      
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
          Offset(
            translateX(
              landmark.x,  
              size,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              landmark.y,  
              size,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
          ),
          1,
          paint,
        );
      });

      
      Rect boundingBox = calculateBoundingBox(pose.landmarks.values.toList());

      
      canvas.drawRect(
        Rect.fromLTRB(
          translateX(boundingBox.left, size, imageSize, rotation, cameraLensDirection),
          translateY(boundingBox.top, size, imageSize, rotation, cameraLensDirection),
          translateX(boundingBox.right, size, imageSize, rotation, cameraLensDirection),
          translateY(boundingBox.bottom, size, imageSize, rotation, cameraLensDirection),
        ),
        boundingBoxPaint,
      );

      
      void paintLine(
        PoseLandmarkType type1,
        PoseLandmarkType type2,
        Paint paintType,
      ) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
          Offset(
            translateX(joint1.x, size, imageSize, rotation, cameraLensDirection),
            translateY(joint1.y, size, imageSize, rotation, cameraLensDirection),
          ),
          Offset(
            translateX(joint2.x, size, imageSize, rotation, cameraLensDirection),
            translateY(joint2.y, size, imageSize, rotation, cameraLensDirection),
          ),
          paintType,
        );
      }

      
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rightPaint);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, leftPaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, rightPaint);

      
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);
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

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}
