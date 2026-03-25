// lib/services/share_service.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Captures a [RepaintBoundary] identified by [key] and opens the OS share sheet.
  static Future<void> captureAndShare(GlobalKey key) async {
    try {
      // 1. Capture the boundary as an Image
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Higher pixelRatio = high resolution
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return;
      final uint8List = byteData.buffer.asUint8List();

      // 2. Save it to a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/earthquest_impact.png').create();
      await file.writeAsBytes(uint8List);

      // 3. Trigger the share sheet
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        text: '🌍 My EarthQuest stats! Check out my impact on our planet. #EarthQuest',
      );
    } catch (e) {
      debugPrint('Error sharing impact: $e');
    }
  }
}
