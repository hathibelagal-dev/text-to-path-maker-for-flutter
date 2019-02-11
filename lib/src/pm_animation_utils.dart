import 'package:flutter/rendering.dart';

/**
* Text to Path Maker
* Copyright Ashraff Hathibelagal 2019
*/

/// Utility class to perform transform operations on a [Path] object
class PMTransform {
  /// Translate and scale a path to desired location and size
  static Path moveAndScale(path, posX, posY, scaleX, scaleY) {
    var transformMatrix = Matrix4.identity();
    transformMatrix.translate(posX, posY);
    transformMatrix.scale(scaleX, -scaleY);
    return path.transform(transformMatrix.storage);
  }
}

/// Utility class to hold the pieces of a [Path] object.
class PMPieces {
  var paths = [];
  var points = [];

  PMPieces(this.paths, this.points);

  static PMPieces breakIntoPieces(Path path, double precision) {
    var metrics = path.computeMetrics();
    var paths = [];
    var cPath = Path();
    var points = [];
    metrics.forEach((metric) {
      for (var i = 0.0; i < 1.1; i += precision) {
        cPath.addPath(
            metric.extractPath(
                metric.length * (i - precision), metric.length * i),
            Offset.zero);
        paths.add(Path()..addPath(cPath, Offset.zero));
        points.add(metric.getTangentForOffset(metric.length * i).position);
      }
    });
    return PMPieces(paths, points);
  }
}
