import 'pm_contour_point.dart';
import 'dart:ui';
import 'package:layouts/layouts.dart';
/**
* Text to Path Maker
* Copyright Ashraff Hathibelagal 2019
*/

/// Represents a Font. Objects of this class must be generated
/// by the FontReader class.
class PMFont {
  var sfntVersion;
  var numTables;
  var searchRange;
  var entrySelector;
  var rangeShift;

  var tables;
  var numGlyphs;

  /// Groups the points of a glyph into contours. Returns a
  /// list of contours
  List contourify(points, endPoints) {
    var contours = [];
    var currentContour = [];
    for (var i = 0; i < points.length; i++) {
      currentContour.add(points[i]);
      for (var j = 0; j < endPoints.length; j++) {
        if (i == endPoints[j]) {
          contours.add(currentContour);
          currentContour = [];
        }
      }
    }
    return contours;
  }

  /// Converts a character into a Flutter [Path] you can
  /// directly draw on a [Canvas]
  Path generatePathForCharacter(cIndex) {
    var svgPath = generateSVGPathForCharacter(cIndex);
    var commands = svgPath.split(" ");

    Path path = Path();

    commands.forEach((command) {
      if (command.startsWith("M")) {
        var coords = command.substring(1).split(",");
        var x = double.parse(coords[0]);
        var y = double.parse(coords[1]);
        path.moveTo(x, y);
      }
      if (command.startsWith("L")) {
        var coords = command.substring(1).split(",");
        var x = double.parse(coords[0]);
        var y = double.parse(coords[1]);
        path.lineTo(x, y);
      }
      if (command.startsWith("Q")) {
        var coords = command.substring(1).split(",");
        var x1 = double.parse(coords[0]);
        var y1 = double.parse(coords[1]);
        var x2 = double.parse(coords[2]);
        var y2 = double.parse(coords[3]);
        path.quadraticBezierTo(x1, y1, x2, y2);
      }
      if (command.startsWith("z")) {
        path.close();
      }
    });

    return path;
  }

  /// Takes a character code and returns an SVG Path string.
  String generateSVGPathForCharacter(cIndex) {
    var glyphId = -1;
    for (var i = 0; i < tables['glyf'].data['glyphs'].length; i++) {
      if (tables['cmap'].data['characterMap'][i] == cIndex) {
        glyphId = i;
        break;
      }
    }

    if (glyphId == -1) {
      print("Character not found.");
      return "";
    }

    var contours = contourify(
        tables['glyf'].data['glyphs'][glyphId]['contourData']['points'],
        tables['glyf'].data['glyphs'][glyphId]['endIndices']);

    var path = "";

    for (var k = 0; k < contours.length; k++) {
      var contour = contours[k];

      var interpolated = [];
      for (var i = 0; i < contour.length - 1; i++) {
        interpolated.add(contour[i]);
        if (!contour[i].isOnCurve && !contour[i + 1].isOnCurve) {
          var t = PMContourPoint();
          t.x = (contour[i].x + contour[i + 1].x) / 2;
          t.y = (contour[i].y + contour[i + 1].y) / 2;
          t.isOnCurve = true;
          interpolated.add(t);
        }
      }
      interpolated.add(contour[contour.length - 1]);
      var lastPoint = contour[contour.length - 1];
      if (!lastPoint.isOnCurve) {
        var t = PMContourPoint();
        t.x = (lastPoint.x + contour[0].x) / 2;
        t.y = (lastPoint.y + contour[0].y) / 2;
        t.isOnCurve = true;
        interpolated.add(t);
      }

      var pos = 0;
      for (var i = 0; i < interpolated.length - 1; i++) {
        if (i == 0) {
          path = path + "M${interpolated[i].x},${interpolated[i].y} ";
        } else {
          if (!interpolated[i].isOnCurve) {
            path = path + "Q${interpolated[i].x},${interpolated[i].y},";
            path = path + "${interpolated[i + 1].x},${interpolated[i + 1].y} ";
            i++;
          } else {
            path = path + "L${interpolated[i].x},${interpolated[i].y} ";
          }
        }
        pos = i;
      }
      if ((pos + 1) < interpolated.length) {
        path = path + "L${interpolated[pos + 1].x},${interpolated[pos + 1].y} ";
      }
      path = path + "z ";
    }
    return path;
  }
}
