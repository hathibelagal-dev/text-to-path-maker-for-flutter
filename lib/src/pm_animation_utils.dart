import 'package:flutter/rendering.dart';

/**
* Text to Path Maker
* Copyright Ashraff Hathibelagal 2019
*/

class PMTransform {
  static Path moveAndScale(path, posX, posY, scaleX, scaleY) {
    var transformMatrix = Matrix4.identity();
    transformMatrix.translate(posX, posY);
    transformMatrix.scale(scaleX, -scaleY);
    return path.transform(transformMatrix.storage);
  }
}

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
        cPath.addPath(metric.extractPath(0, metric.length * i), Offset.zero);
        paths.add(Path()..addPath(cPath, Offset.zero));
        points.add(metric.getTangentForOffset(metric.length * i).position);
      }
    });
    return PMPieces(paths, points);
  }
}
