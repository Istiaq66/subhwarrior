import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Captures a [RepaintBoundary] to a PNG and opens the system share sheet.
class ShareCardService {
  /// Returns `true` once the system share sheet has been invoked, or `false`
  /// if capture silently no-oped (missing boundary or unencodable image).
  /// Callers should treat a caught exception the same as `false`.
  Future<bool> shareBoundary(GlobalKey boundaryKey,
      {required String text}) async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return false;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return false;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/streak_card.png');
    await file.writeAsBytes(bytes.buffer.asUint8List());

    await Share.shareXFiles([XFile(file.path)], text: text);
    return true;
  }
}
